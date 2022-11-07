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

func main() {
	// BitOps Commands
	initCommand := flag.NewFlagSet("init", flag.ExitOnError)
	
	// Init SubCommands
	initSubCommandHelp := initCommand.Bool("help", false, "Prints out `Bitops init` command help.")
	
	// Init SubOptions
	initSubOptionRootDirectory := initCommand.String("directory", "", "Path to directory to create the operations repo in. (Default is the current directory)")

	// Verify that a subcommand has been provided
    // os.Arg[0] is the main command
    // os.Arg[1] will be the subcommand
    if len(os.Args) < 2 {
        fmt.Println("Usage: bitops (init)")
        os.Exit(1)
    }

	switch os.Args[1] {
    case "init":
        initCommand.Parse(os.Args[2:])
    default:
        flag.PrintDefaults()
        os.Exit(1)
    }
	
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
		
		// Supported plugins
		supportPlugins := []string{"aws", "cloudformation", "terraform", "ansible", "helm"}
		
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

		fmt.Println(lineBreak)
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

		// Make folders
		var projectpath = fullprojectname + "/" + environment
		fmt.Println("Creating ["+projectpath+"]")
		os.MkdirAll(projectpath, os.ModePerm)
		
		for _, element := range plugins {
			plugginprojectpath := fullprojectname + "/" + environment + "/" + element
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

	fmt.Println("Bitops is Finished!")
}