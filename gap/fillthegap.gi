#
# fillthegap: My personal GAP utilities
#



#-------------------------------------------------------------------------------
#                                 Remaps
#-------------------------------------------------------------------------------


InstallGlobalFunction( PWD, function()
    Exec("pwd");
end );


InstallGlobalFunction( LS, function(args...)
	local command, flags, dir;

	dir := "";
	flags := "";

	if Length(args) = 1 then
		dir := args[1];

	elif Length(args) = 2 then
    		flags := args[1];
		dir := args[2];
	fi;

    command := Concatenation("ls ", flags, " ", dir);
    Exec(command);
end );


#-------------------------------------------------------------------------------
#                                  General
#-------------------------------------------------------------------------------

# Given a list two-dimensional, get a determined column of its representation
# as a matrix.
# Output: col (a list) as the i column of l.
InstallGlobalFunction( UnpackList, function(l, i)
    local col, j;

    col := [];

    for j in [1..Length(l)] do
        Add(col, l[j][i]);
    od;

    return col;
end );


# Given a list l, return de elements minor than n.
# Output: list containing the elements in l minor than n.
InstallGlobalFunction( LessThanElements, function(l, n)
    local less;
    less := function(i) return i < n; end;

    return Filtered(l, less);
end );


# Given a list l, return de elements major than n.
# Output: list containing the elements in l major than n.
InstallGlobalFunction( GreaterThanElements, function(l, n)
    local greater;
    greater := function(i) return i > n; end;

    return Filtered(l, greater);
end );


# Given a record, return a list containing lists (tuples) which first element
# indicates the record component and the second one, its value.
# Output: result = [ [component, value], ... ]
InstallGlobalFunction( RecordToList, function(record)
    local component, result;

    result := [];
    for component in RecNames(record) do
        Add(result, [component, record.(component)]);
    od;

    return result;
end );


# A regular Print() statement that prints a heading. It is used to print debug
# messages while tracing a function.
InstallGlobalFunction(DBPrint, function(args...)
    local heading, s;

    heading := "[DB] ";
    s := Concatenation([heading], args);

    CallFuncList(Print, s);
end );


# Given a directory object, get the path of it
InstallGlobalFunction( GetDirectoryString, function(dir)
    local path, out;

    path := "";
    out := OutputTextString(path, true);

    PrintTo(out, dir);

    CloseStream(out);

    # Cut the string
    path := path{[12..Length(path)]};
    path := path{[1..Length(path)-2]};

    return path;
end );


# Exec the given command and return its stdout (bad file_name selection)
# Doubts: should I remove the file "file" at the end
InstallGlobalFunction( GetExec, function(cmd)
    local result, temp_dir, temp_dir_path,
    file_name, file_path, file, file_in;

    temp_dir := DirectoryTemporary();
    temp_dir_path := GetDirectoryString(temp_dir);

    file_name := HexSHA256(cmd);
    file := Filename(temp_dir, file_name);
    file_path := Concatenation(temp_dir_path, file_name);

    Exec(Concatenation(cmd, " > ", file_path));

    file_in := InputTextFile(file);

    result := ReadAll(file_in);

    CloseStream(file_in);

    return result;
end );

# Delete trailing linebreak
InstallGlobalFunction( DeleteLinebreak, function(str)
    local formated_str;

    if str[Length(str)] = '\n' then
        formated_str := str{[1..Length(str)-1]};
    else
        formated_str := ShallowCopy(str);
    fi;

    return formated_str;
end );

# Get the current date in ISO8601 format
InstallGlobalFunction( GetDate, function()
    local date;

    date := GetExec("date --iso-8601");

    return DeleteLinebreak(date);
end );

# Security check to not delete not log files
InstallGlobalFunction( IsLogFile, function(str)
    local splitted_str, curr_substr;

    splitted_str := SplitString(str, "-");

    # Check length
    if Length(splitted_str) <> 3 then return false; fi;

    # Check each time field
    if Length(splitted_str[1]) <> 4 then return false; fi;
    if Length(splitted_str[2]) <> 2 then return false; fi;
    if Length(splitted_str[3]) <> 2 then return false; fi;

    for curr_substr in splitted_str do
        if Int(curr_substr) = fail then return false; fi;
    od;

    return true;
end );

# Clean files (be aware! this function removes files in the log_path directory)
InstallGlobalFunction( CleanLogs, function(log_path, num_log_files)
    local ls, list_of_logs,
    files_to_remove, file_name;

    ls := GetExec(Concatenation("ls ", log_path));

    # Dont know the reason why but, if directory is empty, returns GetExec("ls")
    if ls = fail then return; fi;

    ls := DeleteLinebreak(ls);

    # Filter files
    list_of_logs := [];

    for file_name in SplitString(ls, "\n") do
        if IsLogFile(file_name) then
            Add(list_of_logs, file_name);
        fi;
    od;

    Sort(list_of_logs);

    # Remove files
    files_to_remove := list_of_logs{[1..Length(list_of_logs)-num_log_files]};
    for file_name in files_to_remove do
        if IsLogFile(file_name) then
            RemoveFile(Concatenation(log_path, file_name));
        fi;
    od;
end );


# Log to today's file in the directory LOG_PATH
InstallGlobalFunction( LogToDate, function(log_path)
    local RefactorLastLog,
    date, file_today;

    # Refactor last file
    RefactorLastLog := function()
        local ls,
        list_of_files, curr_file_name,
        last_file_name, date_file_name,
        log_dir, last_file, date_file, last_file_in, date_file_out,
        log_to_append, heading;

        heading := "\n\n###################\n   Start session\n###################";

        # Get file name
        ls := GetExec(Concatenation("ls ", log_path));

        # If log_path is empty return
        if ls = fail then return; fi;

        ls := DeleteLinebreak(ls);
        list_of_files := SplitString(ls, "\n");

        last_file_name := fail;

        # Find the "last_" file name
        for curr_file_name in list_of_files do
            if curr_file_name{[1..Minimum(Length(curr_file_name), 5)]} = "last_" and
            IsLogFile(curr_file_name{[Minimum(Length(curr_file_name), 6)..Length(curr_file_name)]}) then
                last_file_name := curr_file_name;
                date_file_name := last_file_name{[6..Length(curr_file_name)]};
                break;
            fi;
        od;

        if last_file_name = fail then return; fi;

        # Open streams
        log_dir := Directory(log_path);

        last_file := Filename(log_dir, last_file_name);
        date_file := Filename(log_dir, date_file_name);

        last_file_in := InputTextFile(last_file);
        date_file_out := OutputTextFile(date_file, true);

        # Read from last_file
        log_to_append := ReadAll(last_file_in);

        # Check if log is empty
        if log_to_append <> fail then
            # Append to date_file
            WriteLine(date_file_out, heading);
            WriteAll(date_file_out, log_to_append);
        fi;

        # Close stream
        CloseStream(last_file_in);
        CloseStream(date_file_out);

        # Delete the last_ file
        RemoveFile(Concatenation(log_path, last_file_name));
    end;

    # Write last log to a dated log file
    RefactorLastLog();

    # Log today's file
    date := GetDate();
    file_today := Concatenation(log_path, "last_", date);

    LogTo(file_today);
end );


# Return a function to cd to gap_dir
InstallGlobalFunction( GetCDTo, function(dir)
    local CDTo;

    CDTo := function()
        ChangeDirectoryCurrent(dir);
    end;

    return CDTo;
end);

#-------------------------------------------------------------------------------
#                                Mathematics
#-------------------------------------------------------------------------------

# Get n expressed as in base b.
# Output: string representing n in base b.
InstallGlobalFunction( InvBase, function (n, b)
    local result, q, r;
    q := n;
    result := "";

    while not q = 0 do
        r := RemInt(q,b);
        q := QuoInt(q,b);

        result := Concatenation(String(r), result);
    od;

    return result;
end );


# Calculate the Minkowski sum of two sets A and B.
# Output: C = A + B.
InstallGlobalFunction( MinkowskiSum, function(A, B)
    local C, a, b;

    C := [];
    for a in A do
        for b in B do
            AddSet(C, a+b);
        od;
    od;

    return C;
end );


# Given a vertex set and a function w representing the weight between two
# vertices, w(v1,v2,args) is false if they are not related and the weight value any
# other scenario. Optional argument means weights, by default true.
# Output: a list of edges E = [ [v1, v2, w(v1,v2,args)] ...] (w(v1,v2,args) is not false).
InstallGlobalFunction( GraphFromWeight, function(V, w, args, more...)
    local E, i, j, act_w, func_args,
    weights;

    # Optional parameter: weights
    weights := Length(more) = 0 or more[1];

    E := [];

    for i in V do
        for j in V do
            func_args := [i,j];
            Append(func_args, args);
            act_w := CallFuncList(w, func_args);
            if act_w <> false then

                # Optional parameter
                if weights then
                    Add(E, [i, j, act_w]);
                else
                    Add(E, [i, j]);
                fi;

            fi;
        od;
    od;

    return E;
end );

InstallGlobalFunction(PrettyPrintOutputs, function(list_functions, list_parameters )
    local current_parameter,
    CurrentFunc, current_result,
    i;

    # Pretty print the parameters
    Print("Parameters:");
    Print("\n");

    for current_parameter in list_parameters do
        Print("  ");
        Print(current_parameter);
        Print("\n");
    od;

    Print("\n");

    # Function calls
    for CurrentFunc in list_functions do
        # Evaluate each function with the given parameters
        current_result := CallFuncList(CurrentFunc, list_parameters);

        # Pretty print the results
        Print("- ");
        Print(NameFunction(CurrentFunc));
        Print(":");
        Print("\n");

        if IsList(current_result) then
            for i in current_result do
                Print("  ");
                Print(i);
                Print("\n");
            od;

        else
            Print("  ");
            Print(current_result);
            Print("\n");
        fi;

        Print("\n");
    od;

end );

#-------------------------------------------------------------------------------
#                            Numerical semigroups
#-------------------------------------------------------------------------------

InstallGlobalFunction(DrawNS, function(S)
    local x;

    for x in [0..Conductor(S)] do
        if x in S then
            Print("O");
        else
            Print("_");
        fi;
    od;
    Print("\n");
end );
