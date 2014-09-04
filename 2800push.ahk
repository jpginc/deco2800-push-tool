2800_push:
{	
 settingsFileLocation := "DECO2800Settings.ini"
 IfNotExist, % settingsFileLocation
 {
  if(! get2800Settings(settingsFileLocation))
  {
   return
  }
 }
 IniRead, startFolder, % settingsFileLocation, settings, file
 if(errorlevel) 
 {
  MsgBox, Error reading the settings file
  return
 }
 IniRead, branch, % settingsFileLocation, settings, branch
 if(errorlevel)
 {
  MsgBox, Error reading the settings file
  return
 }
 MsgBox, 4, Confirm, % "Is this correct?`nYour code folder: " startFolder "`nYour branch: " branch
 IfMsgBox, No
 {
  if(! get2800Settings(settingsFileLocation))
  {
   return
  } 
 }
 IniRead, startFolder, % settingsFileLocation, settings, file
 if(errorlevel) 
 {
  MsgBox, Error reading the settings file
  return
 }
 IniRead, branch, % settingsFileLocation, settings, branch
 if(errorlevel)
 {
  MsgBox, Error reading the settings file
  return
 }
 git := new Git(startFolder, branch)
 git.push()
 ExitApp
}

 

class Git
{
 windowId := ""
 startFolder := ""
 branch := ""
 
 __New(startFolder, branch)
 {
  this.startFolder := startFolder
  this.branch := branch
  run, "C:\Program Files (x86)\Git\bin\sh.exe" --login -i, % startFolder, UseErrorLevel, pid
  if(errorlevel)
  {
   run, "C:\Program Files\Git\bin\sh.exe" --login -i, % startFolder, UseErrorLevel, pid
   if(errorlevel)
   {
    MsgBox, Sorry I can't open GitBash
    return ""
   }
  }
  WinWait, ahk_pid %pid%
  this.windowID := "ahk_pid " pid
  return this
 }
 
 __sendCommand(text)
 {
  IfWinNotExist, % this.windowId
  {
   return false
  }
  WinActivate, % this.windowId
  oldClip := Clipboard
  Clipboard := text
  Send, !{space}ep
  Send, {enter}
  Clipboard := oldClip
  return true
 }
 
 status()
 {
  this.__sendCommand("git status")
  return
 }
 
 showBranch()
 {
  this.__sendCommand("git branch")
  return
 }
 
 checkoutBranch()
 {
  this.__sendCommand("git checkout " this.branch)
  return
 }
 
 checkoutMaster()
 {
  this.__sendCommand("git checkout master")
  return
 }
 
 mergeMasterIntoBranch()
 {
  this.checkoutBranch()
  this.__sendCommand("git merge master")
  return
 }
 
 pullMaster()
 {
  this.checkoutMaster()
  this.__sendCommand("git pull")
  return
 }
 
 mergeBranchIntoMaster()
 {
  this.checkoutMaster()
  this.__sendCommand("git merge " this.branch)
  return
 }
 
 gradleCleanBuild()
 {
  this.__sendCommand("gradle clean build")
  return
 }
 
 push()
 {
  this.showBranch()
  MsgBox, 4, Confirm, Step 1. Are you in your branch?
  IfMsgBox no
  {
   MsgBox, Work in your own branch!!
   return
  }
  this.status()
  MsgBox, 4, Confirm, Step 2. Have you committed your latest code??`nIt should say:`nnothing to commit, working directory clean
  IfMsgBox, no
  {
   MsgBox, Commit more often! what happens if someone else is working on the same file??? there will be merge confilcts!! then you wont know how to fix it so you will just overwrite their changes and they will get really angry. I'm getting angry right now! you make me so angry!
   return
  }
  this.pullMaster()
  MsgBox, 4, Confirm, Step 3. Did master pull and merge correctly? `n(you might have to enter your github username and password
  IfMsgBox no
  {
   MsgBox Please pull master!
   return
  }
  this.mergeMasterIntoBranch()
  MsgBox, 4, Confirm, Step 4. Did master merge into your branch correctly?
  IfMsgBox no
  {
   MsgBox Fix the merge!
   return
  }
  this.gradleCleanBuild()
  MsgBox, 4, Confirm, Step 5. Gradle is now building your branch (which should be up to date with master). Does it build successfully??
  IfMsgBox, No
  {
   MsgBox, I saved you from pushing a broken build! Please send me money.
   return
  }
  this.mergeBranchIntoMaster()
  MsgBox, 4, Confirm, step 6. Your branch should have merged seamlessly into master! right?
  IfMsgBox, No
  {
   MsgBox thats strange...
   return
  }
  this.gradleCleanBuild()
  MsgBox, 4, Confirm, Step 7. Almost there! Gradle is building master (which now contains your branch). Does it build successfully??
  IfMsgBox no
  {
   MsgBox, I saved you from pushing a broken build! Please send me cats
   return
  }
  this.__sendCommand("git push")
  return
 }
}




get2800Settings(settingsFileLocation) 
{
 MsgBox, Select the Folder that contains your code
 FileSelectFolder, startFolder
 if(errorlevel || startFolder == "")
 {
  return
 }
 InputBox, branchName, Branch Name, Enter the name of your branch (this is case sensitive)
 if(errorlevel || branchName == "")
 {
  return
 }

 IniWrite, % startFolder, % settingsFileLocation, settings, file
 IniWrite, % branchName, % settingsFileLocation, settings, branch
 return true
}
