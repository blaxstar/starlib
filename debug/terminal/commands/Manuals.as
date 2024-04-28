package net.blaxstar.starlib.debug.terminal.commands
{
  import net.blaxstar.starlib.debug.printf;

  public class Manuals {

    static public const print:String = 
    "NAME:\n\n" +
    "\tprint - print text to terminal\n\n" + 
    "SYNOPSIS:\n\n" + 
    "\tprint [OPTION][ARGUMENT]\n\n" + 
    "DESCRIPTION:\n\n" + 
    "\tprints data to the terminal.\n" + 
    "\tthe following options are supported:\n\n" +
    "\t-v\tprints the current version of starlib.\n\n" +
    "\tthe following are examples of usage:\n\n"+
    "\tprint -v\n\t// STARLIB VERSION X.X.X\n\n"+
    "\tprint abcde123\n\t// abcde123";

    static public const add:String = 
    "NAME:\n\n" +
    "\tadd - add numbers\n\n" + 
    "SYNOPSIS:\n\n" + 
    "\tadd [...ARGUMENTS]\n\n" + 
    "DESCRIPTION:\n\n" + 
    "\tadds numbers and prints the result to the terminal.\n\n" + 
    "\tthe following are examples of usage:\n\n"+
    "\tadd 5 5\n\t// 10\n\n"+
    "\tadd 1 2 3 4 5\n\t// 15\n\n"+
    "\tadd 5 5 | add 10 10\n\t// 30";
    
    static public const sub:String = 
    "NAME:\n\n" +
    "\tsub - subtract numbers\n\n" + 
    "SYNOPSIS:\n\n" + 
    "\tsub [...ARGUMENTS]\n\n" + 
    "DESCRIPTION:\n\n" + 
    "\tsubtracts numbers and prints the result to the terminal.\n\n" + 
    "\tthe following are examples of usage:\n\n"+
    "\tsub 5 5\n\t// 0\n\n"+
    "\tsub 10 3\n\t// 7\n\n"+
    "\tsub 5 10\n\t// -5";
    
    static public const grep:String = 
    "NAME:\n\n" +
    "\tgrep - print lines that match patterns\n\n" + 
    "SYNOPSIS:\n\n" + 
    "\tgrep PATTERN ... [FILE]\n\n" + 
    "DESCRIPTION:\n\n" + 
    "\tgrep searches for PATTERNS in each FILE.  PATTERN is a single pattern, and grep prints each line (seperated by pipes) that matches that pattern. pattern should not be quoted. if a file is provided, it will search the file. if the file contains a URL to another file that is on the system, it will search recursively for the matching pattern through each file and concatenate all the results from all files.\n" + 
    "\tthe following are examples of usage:\n\n"+
    "\tgrep b booty\n\t// booty\n\n"+
    "\tgrep b c:\\file.txt\n\t// returns every line in c:\\file.txt containing `b`";
    
    static public const eval:String = 
    "NAME:\n\n" +
    "\teval - evaluate objects and properties\n\n" + 
    "SYNOPSIS:\n\n" + 
    "\teval object[.property]\n\n" + 
    "DESCRIPTION:\n\n" + 
    "\tevaluates an object and/or its properties. the objects must be registered prior to runtime, but their properties can be read in real time. it is possible to change this for them to be registered at runtime in the future. the stringified value of the object or property will be printed to the terminal.\n" + 
    "\tthe following are examples of usage:\n\n"+
    "\t// in code: EvalObjectCommand.register_object(\"terminal\", this);\n"+
    "\teval terminal.history_max\n\t// 126, if using default\n\n"+
    "\teval terminal.auto_hide\n\t// true, if using default";
    
    static public const clhs:String = 
    "NAME:\n\n" +
    "\tclearhs\n\n" + 
    "SYNOPSIS:\n\n" + 
    "\tclearhs\n\n" + 
    "DESCRIPTION:\n\n" + 
    "\tclears the terminal's input history.\n" + 
    "\tthe following are examples of usage:\n\n"+
    "\tclearhs\n\t// outputs `history cleared.`\n\n";
  }
}