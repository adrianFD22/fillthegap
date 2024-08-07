#
# fillthegap: My personal GAP utilities
#

# Remaps
DeclareSynonym( "CD", ChangeDirectoryCurrent);
DeclareGlobalFunction( "PWD" );
DeclareGlobalFunction( "LS" );

# General
DeclareGlobalFunction( "UnpackList" );
DeclareGlobalFunction( "LessThanElements" );
DeclareGlobalFunction( "GreaterThanElements" );
DeclareGlobalFunction( "RecordToList" );
DeclareGlobalFunction( "DBPrint" );
DeclareGlobalFunction( "GetDirectoryString" );
DeclareGlobalFunction( "GetExec" );
DeclareGlobalFunction( "DeleteLinebreak" );
DeclareGlobalFunction( "GetDate" );
DeclareGlobalFunction( "IsLogFile" );
DeclareGlobalFunction( "LogToDate" );
DeclareGlobalFunction( "CleanLogs" );
DeclareGlobalFunction( "GetCDTo" );

# Mathematics
DeclareGlobalFunction( "InvBase" );
DeclareGlobalFunction( "MinkowskiSum" );
DeclareGlobalFunction( "GraphFromWeight" );
DeclareGlobalFunction( "PrettyPrintOutputs" );

# Numerical semigroups
DeclareGlobalFunction( "DrawNS" );
