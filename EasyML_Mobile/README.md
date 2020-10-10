


# Mobile Application

The mobile application was built using the Flutter UI framework. The framework supports cross-platform mobile development.

## Table of Contents

* [Home page](#home-page)
* [Model creation](#model-creation)
* [Login and Registration](#login-and-registration)
* [User profile](#user-profile)
* [Adding a dataset](#adding-a-dataset)
* [Model Page](#model-page)
* [Description Section](#description-section)
* [Model Parameters Section](#model-parameters-section)
* [Model Training Section](#model-training-section)
* [Model Code](#model-code)
* [Model Training Dialog](#model-training-dialog)
* [Trained Model Information](#trained-model-information)
* [Data Set Page](#data-set-page)


  
  
## Home Page

 When user opens the app, they are greeted with this page. It contains the profile avatar from which the user can open a dialog to register or login. If they are logged in, the can view and alter their profile information from that dialog. It also has two lists containing the models and the data sets the user has. Because the data sets are primarily for users who want to train their model, which is related to their account, they'll have to log in in order to view their data sets. As for the models, if the user is not logged in, it will only show the models that are local to the device. If the user is logged in, it will also show the models stored on the server, with a cloud icon (:cloud:) that indicates that the model is related to the account and is stored on the cloud. If the user is logged in, they can refresh their cloud models by pulling up. The cloud models are cached to the user's device so that they can view them even if they don't have an internet connection. If the data of the model stored on the cloud is different from the cached model, the cloud icon is crossed out to indicate a contradiction. From the home screen, the user can open up a dialog to create a model. If they are logged in, the can also open up a dialog to add a data set. There also is a connection indicator that appears if the application fails to connect to the server.

<p align="center">
    <img width = "80%" src="/images/home.jpg"> 
</p>

  The user can long press a model or a data set from the lists which shows a dialog that allows them to rename or delete the item they selected.
  
 <p align="center" width = "100%">
   <img width = "33%" height = "300" src="/images/edit model.jpg"> 
   <img width = "10%" height = "0" src=".."> 
   <img width = "33%" height = "300" src="/images/edit dataset.jpg"> 
</p>

## Model Creation

When the user taps (:heavy_plus_sign: New model), they are presented with a dialog from which they can create their machine learning model. The algorithms are presented in a scroll-able list with a brief description of each algorithm under it. If the user wishes to quickly select a model, they can switch to a brief view from which all the models are presented in a grid without description. The user enters the name of their model and creates it. The model is by default created locally on the device. No duplicate model names are allowed.

 <p align="center" width = "100%">
   <img width = "33%" height = "400" src="/images/add model detailed.jpg"> 
   <img width = "10%" height = "0" src=".."> 
   <img width = "33%" height = "400" src="/images/new model brief.jpg"> 
</p>

## Login and Registration

When the user taps the profile avatar when not logged in, a dialog containing a login form will pop up. The user can enter their username and password in order to log in. If they do not have an account, they can switch to the registration form where they can sign up a new account with a username, an email address and a password. Once the user logs in, the dialog is switched to their profile dialog. When the user registers, they are switched to the login dialog, with their registration credentials filled in.

 <p align="center" width = "100%">
   <img width = "33%" height = "400" src="/images/login.jpg"> 
   <img width = "10%" height = "0" src=".."> 
   <img width = "33%" height = "400" src="/images/register.jpg"> 
</p>

## User Profile

When the user taps the profile avatar while they're logged in, a dialog pops up with their username and profile picture. They can enable or disable notifications and upload their profile picture. The also can logout. Upon logging out, any cloud models that are cached will be removed from the local storage.

<p align="center">
    <img width = "30%" src="/images/profile picture.jpg"> 
</p>

## Adding a dataset
When the user taps (:heavy_plus_sign: New data set), a dialog showing the different types of data sets pops up. The user can choose the file type of their data set, give it a name and add it. A description about each data set file is provided too.

<p align="center">
    <img width = "30%" src="/images/new dataset.jpg"> 
</p>

## Model Page

The header part of the model page contains the model name and type. If the user is logged it, it also has an indicator that shows the status of the model (if locally saved or cached from the cloud). If the model is locally saved, a cloud upload icon is shown with a brief text telling the user that the model is only locally saved. If they wish to upload the model to the server, they have to tap the cloud upload icon. If the model is cached from the cloud and no contradictions are found between it and what's on the cloud, a cloud icon with a tick inside it is shown indicating that the model is cached correctly. If a contradiction is detected, a cloud download is shown with a text telling the user that a contradiction is detected. They can either tap it to change the cached model to match the model on the cloud, or save the cached model to the cloud from the save button we will discuss later.

 <p align="center" width = "100%">
   <img width = "33%" height = "400" src="/images/header empty.jpg"> 
   <img width = "10%" height = "0" src=".."> 
   <img width = "33%" height = "400" src="/images/header upload.jpg"> 
</p>

 <p align="center" width = "100%">
   <img width = "33%" height = "400" src="/images/header saved.jpg"> 
   <img width = "10%" height = "0" src=".."> 
   <img width = "33%" height = "400" src="/images/header contradiction.jpg"> 
</p>

## Description Section
A description about the machine learning algorithm of this model.

## Model Parameters Section
This section contains the main parameters of the machine learning algorithm. It also has an expandable section for more parameters for users who are more advanced. Each parameter has a help icon that when pressed shows an explanation of the parameter. There are many types of parameters, boolean, numeric, choice and others. After the user changes the parameters to their needs they can save the model. After the model is saved, they can choose to view the code for their model which opens another page.
      
 <p align="center" width = "100%">
   <img width = "33%" height = "600" src="/images/model params 1.jpg"> 
   <img width = "10%" height = "0" src=".."> 
   <img width = "33%" height = "600" src="/images/model params 2.jpg"> 
</p>

## Model Training Section
This section only appears if the model is saved to the server. In this section, the user can choose the data set they wish to train their model with. It also includes the buttons for training the model and viewing its results after the training is finished.

 <p align="center" width = "100%">
   <img width = "30%"  src="/images/train.jpg"> 
   <img width = "6%" height = "0" src=".."> 
    <img width = "50%"  src="/images/model page.jpg"> 
</p>


## Model Code

In the model page, when the model is saved, the user will be able view their code through a button. It will take them to this page where they can view the Python source code with syntax highlighting. They can choose to read it in light or dark mode, whichever they prefer. They also can save the code as a Python source code file or a Jupyter Notebook file, which presents them with a dialog to choose the file location to save the file to.
  
  <p align="center" width = "100%">
   <img width = "33%" height = "600" src="/images/code light.jpg"> 
   <img width = "33%" height = "600" src="/images/code dark.jpg"> 
</p>

## Model Training Dialog
After the user selects their data set in the model page, they can press the train button which opens this dialog. In this dialog, the user can specify the amount of data to use for training and the amount to use for testing. If the user uses an inappropriate amount, a warning is displayed. They also choose the normalization method for their data. They can choose to not normalize their data, or normalize it using minimum-maximum normalization or to standardize  their data using the mean and standard deviation. Then, they can select the label and the features from the data set to use for training. They then can press the train button to start training their model on the machine learning server.

 <p align="center" width = "100%">
   <img width = "33%" height = "600" src="/images/model training 1.jpg"> 
   <img width = "10%" height = "0" src=".."> 
   <img width = "33%" height = "600" src="/images/model training 2.jpg"> 
</p>

After the user presses the train button an indicator on the model header will show that the model is training. After the training is finished, a notification is received telling the user that the model finished training.
<p align="center">
<img width = "70%" src="/images/notification.jpg"> 
</p>

## Trained Model Information
After the model is trained successfully, the user will be able to view the information about the trained model, which is in its own page. In this page, the user can see the scoring metrics that tell him/her how good the trained model actually is. They also can view the parameters the model was trained using alongside with the data set used for training, which columns were dropped and which column was the label. They also can download the trained model as a Python pickle-encoded file. Instructions are provided on how to open and use the trained model. Also, they can upload a data set that they want to predict the output for and get the prediction directly.

 <p align="center" width = "100%">
   <img width = "33%" height = "600" src="/images/trained model page.jpg"> 
   <img width = "3%" height = "0" src=".."> 
   <img width = "33%" height = "600" src="/images/trained model download.jpg"> 
</p>

 <p align="center" width = "100%">
   <img width = "33%" src="/images/trained model predict.jpg"> 
   <img width = "3%" height = "0" src=".."> 
   <img width = "33%" height = "600" src="/images/trained model dataset.jpg"> 
</p>

## Data Set Page
This page is very similar to the model page. It allows you to upload your data set file to the machine learning server. If the file is successfully uploaded and is correctly formatted, it will display some information about the data set.

<p align="center">
<img width = "70%" src="/images/data set.jpg"> 
</p>

