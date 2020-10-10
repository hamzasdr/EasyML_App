# EasyML_App Overview


<!-- TABLE OF CONTENTS -->
## Table of Contents

* [About the Project](#about-the-project)
  * [Problem Statement](#problem-statement)
  * [Objectives and Scope](#objectives-and-scope)
  * [Built With](#built-with)
* [Features](#features)
* [Architecture](#architecture)
  * [General Architecture](#general-architecture)
  * [Mobile Application](#mobile-application)
  * [Data and API Server](#data-and-api-server)
  * [Machine Learning Server](#machine-learning-server)
  * [Urban Airship](#urban-airship)
* [Conclusion](#conclusion)
  * [Summary](#summary) 
  * [Future Work](#future-work) 
<!-- ABOUT THE PROJECT -->
## About The Project

### Problem Statement
A lot of people are faced with many barriers when trying to dive into the machine learning world. Some of them lack the code experience that enables them to use it, while others don't have machines that are computationally able to train their models on.  
There are some tools that enable users to build models graphically, but most of them are too complex for them to use. Moreover, the majority of them doesn't target the most popular device of this generation, the smartphone.

### Objectives and Scope
We aim to build a mobile applications that enables users to start exploring the world of machine learning through building models in a user-friendly interactive way without the need of code experience. From there, they can also train their models on whatever data they want without the need of a powerful device, and make predictions based on these trained models. It also allows people who have some code experience to quickly generate code that builds their model for them or obtain their already-built, ready-to-use trained model.
### Built With
* [Flutter](https://flutter.dev/)
* [Django](https://www.djangoproject.com/)
* [Django REST Framework](https://www.django-rest-framework.org/)
* [Flask](https://flask.palletsprojects.com/en/1.1.x/)
* [Scikit-learn](https://scikit-learn.org/)

<!-- Features -->
## Features

- **A cross-platform mobile application that allows users to**:

    * Build their own machine learning models and specify their parameters quickly. The process is made easy for beginners through descriptions and explanations of every               model and parameter.
    *  Generate ready-to-use code for their machine learning models.
    *  Train their model without the need of a powerful device using their own data sets.
    *  receive notifications about the training of their model and view the training results
    *  Use their trained models to predict new data.
    *  Download their trained models to use them.

- **The Apllication supports the following machine learning algorithms**:
    *  Linear Regression
    *  Multilayer Perceptron Feed Forward Neural Network
    *  K Nearest Neighbors
    *  Decision Tree
    *  Random Forest
    *  K means clustering

- **Since the system can be interacted with directly through the API, this allows for the integration of our machine learning system into other systems for automation without the need to the mobile application.**

<!-- Architecture -->
## Architecture

### General Architecture
The architecture of our system mainly consists of 4 entities.

* Mobile Application
* Data and API Server
* Machine Learning Server
* Urban Airship  
The following figure illustrates the system architecture.
<p align="right">
    <img src="/images/architecture.png"> 
</p>

   
### [Mobile Application](https://github.com/hamzasdr/EasyML_App/tree/master/EasyML_Mobile)
From the mobile application, the user can create machine learning models and set their parameters. From then, they can choose to generate and save the Python source code for that model which they can run on any Python interpreter. They also can save it as a Jupyter Notebook file which is a popular file format used in data science and machine learning. **This all can be done locally within the mobile application itself and doesn't require any internet connection.** The application also acts as graphical interface that communicates with the API and machine learning servers. The user can choose to create an account in order to use the services provided by servers from saving their models on the cloud, uploading their data sets, training their models and using the trained models to predicting new data. 
### [Data and API Server](https://github.com/hamzasdr/EasyML_App/tree/master/Data%20and%20API%20Server)

The Data and API server exposes a public API that handles the requests coming from the clients. The requests can range from login requests to training requests. This API is used by the mobile application, and can be integrated into other systems if needed. The server also acts as a middleman between the clients and machine learning server, authenticates the users and validates the data it receives. It's the only entity that directly communicates with the database and manages its information. It also exposes an internal API that can only be used by the machine learning server.  
This server also communicates with the Urban Airship service in order to provide push notifications about model training to the mobile application users.

### [Machine Learning Server](https://github.com/hamzasdr/EasyML_App/tree/master/Machine%20Learning%20Server)

The machine learning server is the computational power of the system. The server does not have its own database, and communicates with the data server through the internal API to authenticate users and get any information it needs. The user only communicates with this server when dealing with uploads and downloads of data set files and trained models, because they are large in size, so it is inefficient to store them in a database and even more inefficient to upload them to the data server and then forward them to this server. For any other operations, this server only accepts requests from the data server.  
For training, it receives a request from the data server with the training parameters for a specific model and the target data set and proceeds to start training the model. It also notifies the data server of the results of the training.

### Urban Airship
The purpose of using the Urban Airship service is to provide push notifications to the mobile application users when their model succeeds or fails at training. When the data and API server receives a notification from the machine learning server about a model, it requests the service to send push notifications to the mobile devices associated with the owner of that model.


## Conclusion

### Summary
There are several GUI-powered machine learning platforms, but none of them are very easy to use, and none are mobile focused. Our solution was a mobile application with an easy-to-use interface that makes the user able to dive deeper into the world of machine learning with much less barriers.
### Future Work
*  Add options for data pre-processing and analysis.
*  Add more machine learning algorithms, including more powerful ones such as convolutional neural networks.
*  Provide continuous and graphical feedback about the progress of training.
*  Allow for data set options other than textual data such as images and voice.
*  Have the option to optimize the model parameters depending on the data set.
*  Deploy the machine learning server on a cluster in order to increase its power substantially.
*  Implement edge computing where the computing power of the mobile devices can be used to accelerate training.
