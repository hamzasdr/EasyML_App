
# Data and API Server

The data and API server was built using the Django and Django REST Frameworks.

## Table of Contents

* [Database](#database)
* [REST API](#rest-api)
  * [Public API](#public-api)
  * [Internal API](#internal-api)


## Database
Django manages the database using an ORM that by default works on SQLite. This means that we don't need to perform SQL queries explicitly. Instead, for any needed table, we define a class that extends Django's  **_Model_** class, define all the fields for the class using specific model fields provided from Django, and make database migrations which Django automatically translates into the appropriate SQL queries needed to build the tables. The same classes are used to instantiate objects and save them and to query objects, which also get translated automatically to the needed SQL queries. Django also provides ready models for user accounts and user groups and admin accounts.
For our application purposes, we need the following classes:

1. **CustomUser:** We needed to change the default user model provided by Django. This was done because we wanted to add a special flag that identifies the user used by the machine learning server. This flag allows it to use the internal API.
2. **Model:** This class identifies machine learning models. It is used as a parent class for all the other machine learning models, with each model having its own parameters as fields in the class.
3. **Data:** This class holds some basic information about the data sets.
4. **Device:** This class is needed to manage the user's devices in order to send appropriate push notifications.

As mentioned before, these classes automatically generate database tables including their fields and other fields that are used by Django for management.
The following figure shows the UML class diagram of our database.

<p align="center">
<img src="/images/uml.png"> 
</p>


As shown in the Figure, the Model class is a parent class for all the different machine learning algorithm models. Unfortunately, Django's support for polymorphism is limited. Luckily, we found a Python librariy **django-polymorphic** adds a class called **_PolymorphicModel_** that makes dealing with polymorphism much easier. This class adds some fields to the database tables which keeps track of the parent and children object types and makes dealing with them much easier.


## REST API

The Django REST Framework builds on top of Django and enables building APIs in an easier way. The API itself is made up from views that expose the database objects through a process called serialization. Serializer are classes that can encode and decode and validate the data for database objects, and are the middleman between the database objects and the views. For each model class, we need to create a serializer. The view uses the serializer to validate the data from the requests made to the API and creates, updates, gets or deletes objects accordingly.  
    For our data and API server, we had two APIs. We have a public API that is used by the mobile application and anybody who wants to integrate our system into theirs programmatically. We also have an internal API used by the machine learning server in order to authenticate users and retrieve data when needed.

### Public API
The public API allows for basic operations like login and registration. It allows for CRUD (create, read, update and delete) operations on the different objects the user owns, such as models and data sets. The API makes sure that the user is authenticated and is permitted to do these operations on the data.  
It also exposes two end points that fetch information from the machine learning server about the user's models and data sets.  
The used authentication is **token authentication**, where the user obtains a token through an endpoint and inserts it into the head of their requests.
Another endpoint it exposes is a train endpoint from which the user can request a certain model to be trained using a certain data set. Then, the parameters of that machine learning model are extracted from the database and forwarded to the machine learning server at which the training is done.  
The following table shows the different endpoints exposed by the public API.  

<p align="center">
<img src="/images/public_api.png"> 
</p>

### Internal API
The internal API is used by the machine learning server in order to communicate with the data server. The machine learning server has its own account which has a privilege flag set to true. This flag can only be set by an administrator. This allows for scalability in case more machine learning servers need to be added. Any access to this API end point is authenticated then checked for the flag. The machine learning server uses this endpoint to retrieve database entries of users, models and data sets. It also can authenticate users when needed. The other server also sends notifications about the training of the models through this API.  
The following table shows the different endpoints in the internal API. 

<p align="center">
<img src="/images/internal_api.png"> 
</p>


The notify endpoint receives status updates from the machine learning server about the training of models. It updates the necessary fields in the database and sends a push notification request to the Urban Airship service in order to notify all the mobile users that of the training status.
