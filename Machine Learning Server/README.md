## Table of Contents

* [Machine Learning server](#machine-learning-server)
  * [Data Server endpoints](#data-server-endpoints)
  * [Download and upload endpoints](#download-and-upload-endpoints)

# Machine Learning server

The machine learning server was built using the Flask framework. Flask provides and lightweight and easy way to quickly build micro-services, rather than a full stack system like Django.  
For machine learning, we used the scikit-learn Python library which provides a wide selection of machine learning algorithms alongside with Pandas, one of the most most popular data analysis libraries amongst data scientists.
This server mainly has two types of endpoints:

## Data Server endpoints

These endpoints are exclusively used by data server in order to retrieve information regarding data set files and trained models. There is also an endpoint used by the data server to start model training. The data server sends the token of the user used by the machine learning server as authentication, since only both of them know this token.  
all the parameters are placed in the body.  

<p align="center">
<img src="/images/data_ml_api.png"> 
</p>

In the training endpoint, the machine learning server validates the requested model and its parameters. Then, it creates a new process and starts the training there. It then returns a **HTTP 202 ACCEPTED**
indicating that the training started. After the training finishes, either successfully or not, it contacts the data server giving it the status of training.  
In the training process, non-numeric columns need to be encoded in order to be used for training. The encodes need to be saved and re-used when any prediction needs to be performed using the model. The normalization scaler also needs to be saved so that the prediction data is normalized exactly the same as the training data. After the training finishes, the trained model is saved alongside with both the encoders and the normalization scaler. When the user wants to make a prediction, the saved model is opened and the same normalize scaler and encoders are used on the prediction data. They are also included in the model file the user downloads.

## Download and upload endpoints

These endpoints are public endpoints that involve uploading and downloading large files related to models and data sets. We didn't plan to expose any endpoints from this server to the public, but we thought that any other method involving these large files would add unnecessary overhead. For these endpoints, the server expects to receive the same authentication credentials used to authenticate at the data server, and forwards them to the other server to authenticate the user.

<p align="center">
<img src="/images/data_ml_api_2.png"> 
</p>
