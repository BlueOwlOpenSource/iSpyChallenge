# iSpyChallenge

This repository contains an Xcode project that is used as a starting point for the iSpy App programming challenge used.

## Process

The goal of the challenge is to provide a springboard for you to be able to really demonstrate your core strengths.  During a three hour block of time you will be asked to build a portion of a small iOS application.  The Xcode project in this repo contains a starting point for your work. There are three tabs in the application. The first two are placeholders for  your work. The third tab contains a data browser for exploring the sample data included with the project.

You may use your own computer system for this exercise.  

Clone the project on GitHub and work from your public repo.  When finished with the challenge please create your own GitHub repo and push your work to it so we can take a look at the results.  Be sure to tell your interviewer what your GitHub user name is and the name of your repo.  For example, if your GitHub username is 'RockStar' and you create a public repo called 'mySpyChallenge', the following commands will get you started.

````
$ cd ~/Desktop
$ git clone git@github.com:BlueOwlDev/iSpyChallenge.git --origin BlueOwl mySpyChallenge
$ cd mySpyChallenge
$ git remote add origin git@github.com:RockStar/mySpyChallenge.git
$ git push -u origin master
````

Your goal is to implement the "New Challenge" and "Near Me" tabs in the app.  Refer to the documentation provided earlier for details on the model objects and what functionality the user interface should include.

You will have 3 hours to work on the project. 

## Xcode Project Overview

The model objects for the app are provided, along with some sample data for use during the exercise.  All data is maintained in memory and is loaded from sample JSON files, via a mock API service, when the app launches.
 
Access to the sample data is provided via the DataController class.  You will need to utilize this class in order to complete the challenge.  iSpyTabBarController constructs the DataController and passes it into each of its view controllers (currently only DataBrowserViewController).  Additionally, there are convenience functions for navigating DataController's data in DataController+iSpy.swift.

## Screen Shots

<kbd><img src="NewChallenge.png" alt="New Challenge" width="240"/>

<kbd><img src="NearMe.png" alt="Near Me" width="240"/>

<kbd><img src="DataBrowser.png" alt="Data Browser" width="240"/>
