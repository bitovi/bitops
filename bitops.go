package main

import (
	"flag"
	"os"
	"fmt"
	"strings"
	"bufio"
	"log"
)

var lineBreak string = "#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#"
var loopBreak string = "-------------------------------------"
var confirmResponse string = "Is this correct?"
var helpResponse string = `
BitOps:
  init 		- Initializes a new Operations Repo
  add-new	- Add a new environment to an existing Operations Repo
`
var supportPlugins []string = []string{"aws", "cloudformation", "terraform", "ansible", "helm"}

// askForConfirmation asks the user for confirmation. A user must type in "yes" or "no" and
// then press enter. It has fuzzy matching, so "y", "Y", "yes", "YES", and "Yes" all count as
// confirmations. If the input is not recognized, it will ask again. The function does not return
// until it gets a valid response from the user.
func askForConfirmation(s string) bool {
	reader := bufio.NewReader(os.Stdin)

	for {
		fmt.Printf("%s [y/n]: ", s)

		response, err := reader.ReadString('\n')
		if err != nil {
			log.Fatal(err)
		}

		response = strings.ToLower(strings.TrimSpace(response))

		if response == "y" || response == "yes" {
			return true
		} else if response == "n" || response == "no" {
			return false
		}
	}
}

// exists returns whether the given file or directory exists
func exists(path string) (bool, error) {
    _, err := os.Stat(path)
    if err == nil { return true, nil }
    if os.IsNotExist(err) { return false, nil }
    return false, err
}


func ConfirmEnvironment() string {
	var environment string

	fmt.Println(lineBreak)
	for {
		fmt.Print("What Environment are we building? : ")
		fmt.Scanln(&environment)

		if environment == "" {
			continue
		}

		fmt.Println("Creating Environment: ["+environment+"]")
		response := askForConfirmation(confirmResponse)
	
		if response {
			fmt.Println("Creating ["+environment+"]")
			break
		}
	}
	return environment
}

func ConfirmTools() []string {
	plugins := []string{}

	for _, element := range supportPlugins {
		response := askForConfirmation("Are you using [" + element + "]?")
		if response {
			fmt.Println("Creating [" + element + "]")
			plugins = append(plugins, element)
		}else{
			fmt.Println("Skipping [" + element + "]")
		}
		fmt.Println(loopBreak)
	}
	return plugins
}

func CreateEnvironment(plugins []string, projectpath string) {
	for _, element := range plugins {
		plugginprojectpath :=  projectpath + "/" + element
		fmt.Println("Creating ["+plugginprojectpath+"]")
		os.MkdirAll(plugginprojectpath, os.ModePerm)

		// Creating README
		readme := plugginprojectpath + "/README.md"
		readmeMsg := element + " IaC goes in this folder\nFind more information on this plugin at https://github.com/bitops-plugins"
		err := os.WriteFile(readme, []byte(readmeMsg), 0755)
		if err != nil {
			fmt.Printf("Unable to write file: %v", err)
		}

		// Creating bitops.config.yaml
		bitopsconfig := plugginprojectpath + "/bitops.config.yaml"
		bitopsconfigMsg := element + ":\n\toptions: {}\n\tcli: {}"
		err = os.WriteFile(bitopsconfig, []byte(bitopsconfigMsg), 0755)
		if err != nil {
			fmt.Printf("Unable to write file: %v", err)
		}

		// Creating before and after hook directories
		beforehookpath := plugginprojectpath + "/bitops.before-deploy.d"
		afterhookpath := plugginprojectpath + "/bitops.after-deploy.d"
		os.MkdirAll(beforehookpath, os.ModePerm)
		os.MkdirAll(afterhookpath, os.ModePerm)
	}
}


func main() {
	// BitOps Commands
	initCommand := flag.NewFlagSet("init", flag.ExitOnError)
	addNewCommand := flag.NewFlagSet("add-new", flag.ExitOnError)
	//validateCommand := flag.NewFlagSet("validate", flag.ExitOnError)

	
	// #~# INIT #~#
	// Init SubCommands
	initSubCommandHelp := initCommand.Bool("help", false, "Prints out `Bitops init` command help.")
	// Init SubOptions
	initSubOptionRootDirectory := initCommand.String("directory", "", "Path to directory to create the operations repo in. (Default is the current directory)")
	// #~#~#~#~#~#~#

	// #~# VALIDATE #~#
	// #~#~#~#~#~#~#~#

	// #~# ADD-NEW #~#
	// addNewSubCommandOpsRepo := addNewCommand.String("Operations Repo", "", "Path to the Operations Repo being updated (Required).")
	// #~#~#~#~#~#~#~#


	// Verify that a subcommand has been provided
    // os.Arg[0] is the main command
    // os.Arg[1] will be the subcommand
    if len(os.Args) < 2 {
        fmt.Println(helpResponse)
		flag.PrintDefaults()
        os.Exit(1)
    }

	switch os.Args[1] {
    case "init":
        initCommand.Parse(os.Args[2:])
	case "add-new":
        addNewCommand.Parse(os.Args[2:])
    default:
		fmt.Println(helpResponse)
        flag.PrintDefaults()
        os.Exit(1)
    }

	// INIT COMMAND
	if initCommand.Parsed() {
		var rootFolderPath string = "."
		
		// Help command
		if *initSubCommandHelp == true {
            initCommand.PrintDefaults()
            os.Exit(1)
        }

		// Directory SubCommand
		if *initSubOptionRootDirectory != "" {
			// Returns: Bool, Err - Checks if path to folder/file exists
			rootFolderCreate, err := exists(*initSubOptionRootDirectory)
			
			if err == nil { }
			if rootFolderCreate {
				rootFolderPath = *initSubOptionRootDirectory
			}else{
				fmt.Println("Not a valid path: ["+*initSubOptionRootDirectory+"]")
				initCommand.PrintDefaults()
            	os.Exit(1)
			}
		}

		fmt.Println("Using root directory: [" + rootFolderPath + "]")
		
		// Generate Ops Repo
		var projectname string
		var fullprojectname string
		fmt.Println(lineBreak)
		for {
			fmt.Println("Creating an Operations Repo!")
			fmt.Print("What is the project name? : ")
			fmt.Scanln(&projectname)

			if projectname == "" {
				continue
			}
			
			fullprojectname = "Operations_"+projectname
			fmt.Println("Generating Operations Repo: [" + fullprojectname + "]")
			response := askForConfirmation(confirmResponse)
		
			if response {
				fmt.Println("Creating [Operations_"+projectname+"]")
				break
			}
		}

		// Environment
		environment := ConfirmEnvironment()
		fmt.Println(lineBreak)

		// Plugins
		plugins := ConfirmTools()

		// Make folders
		var projectpath = rootFolderPath + "/" + fullprojectname + "/" + environment
		fmt.Println("Creating ["+projectpath+"]")
		os.MkdirAll(projectpath, os.ModePerm)
		
		CreateEnvironment(plugins, projectpath)
    }

	// ADD-NEW COMMAND
	if addNewCommand.Parsed() {	
		var opsRepoPath string = ""
		addNewCommandUsage := `Usage: bitops add-new (env|tool)`
		
		if addNewCommand.Arg(0) == "" {
			fmt.Println(addNewCommandUsage)
			addNewCommand.PrintDefaults()
			os.Exit(1)
		}
		
		addNewSubCommand := addNewCommand.Arg(0)
		switch addNewSubCommand{
		case "env":
			opsRepoPath := addNewCommand.Arg(1)
			exists, err := exists(opsRepoPath)
			if err == nil {}
			if exists == false {
				fmt.Println("Usage: bitops add-new env /path/to/operations_repo")
				os.Exit(1)
			}

			fmt.Println("Adding new Environment")

			environment := ConfirmEnvironment()
			plugins := ConfirmTools()
			addNewpath := opsRepoPath + "/" + environment

			CreateEnvironment(plugins, addNewpath)

		case "tool":
			
			
			fmt.Println("Adding new tool to Environment folder")
		default:
			fmt.Println(addNewCommandUsage)
			addNewCommand.PrintDefaults()
			os.Exit(1)
		}
		
		os.Exit(1)
		
		opsRepoPath = addNewCommand.Arg(0)
		opsRepoExists, err := exists(opsRepoPath)

		if err == nil {}
		if opsRepoExists == false {
			fmt.Println("Operations Repo Path doesn't exist. ["+opsRepoPath+"]")
			fmt.Println(addNewCommandUsage)
			addNewCommand.PrintDefaults()
			os.Exit(1)
		}
		fmt.Println("Updating Operations Repo: [" + opsRepoPath + "]")

		
		// for _, element := range supportPlugins {
		// 	response := askForConfirmation("Are you using [" + element + "]?")
		// 	if response {
		// 		fmt.Println("Creating [" + element + "]")
		// 	}else{
		// 		fmt.Println("Skipping [" + element + "]")
		// 	}
		// 	fmt.Println(loopBreak)
		// }

	}

	fmt.Println("Bitops is Finished!")
}