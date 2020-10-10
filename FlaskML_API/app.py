from multiprocessing.context import Process

from flask import Flask, request, json, jsonify, send_from_directory, send_file, Response, stream_with_context
from pandas.errors import EmptyDataError

from data_files import file_extensions
from data_models import models, get_columns

from data_server import DataServer

from dirs import DATA_DIR, MODEL_DIR, check_file, get_data_dir, read_file_chunks, get_model_dir, PREDICT_DIR, \
    get_model_info_dir, get_predict_dir

import os

app = Flask(__name__)

TRAIN_ARGS = [('model_type', str,), ('model_id', int,), ('user_id', int,), ('data_id', int,)]
GET_DATA_INFO_ARGS = [('user_id', int,), ('data_id', int,)]
GET_MODEL_INFO_ARGS = [('user_id', int,), ('model_id', int,)]
UPLOAD_DIRECTORY = "./project/api_uploaded_files"
authenticate = True

if not os.path.exists(UPLOAD_DIRECTORY):
    os.makedirs(UPLOAD_DIRECTORY)


# @app.before_request
# def _authenticate():
#     if authenticate:
#         if DataServer.get_server_token() is None:
#             login = DataServer.data_server_login()
#             print(DataServer.data_server_token)
#             # print('Authenticated' if login is bool else 'Error')


@app.route('/', methods=["HEAD", "GET"])
def head():
    return '', 200


@app.route('/train/', methods=["POST"])
def train():
    # validate if the request is JSON or not
    if not request.is_json:
        return jsonify({'detail': 'Invalid format'}), 400

    # check if the data server is the one requesting by checking the token
    if not DataServer.check_data_token(request):
        return jsonify({'detail': 'Unauthorized'}), 401

    # validate main request arguments
    request_data = request.get_json()
    missing_args = [item[0] for item in TRAIN_ARGS if item[0] not in request_data]
    if len(missing_args) != 0:
        return jsonify({'detail': 'Missing arguments', 'missing_args': missing_args}), 400
    invalid_args = \
        [
            {
                'arg': TRAIN_ARGS[index][0],
                'sent_type': type(request_data[TRAIN_ARGS[index][0]]).__name__,
                'expected_type': TRAIN_ARGS[index][1].__name__
            }
            for index in range(len(TRAIN_ARGS))
            if type(request_data[TRAIN_ARGS[index][0]])
               != TRAIN_ARGS[index][1]
        ]
    if len(invalid_args) != 0:
        return jsonify({'detail': 'Invalid types for arguments.', 'invalid_args': invalid_args}), 400

    model_type = request_data['model_type']
    model_id = request_data['model_id']
    user_id = request_data['user_id']
    data_id = request_data['data_id']

    # validate if the model type is valid
    if model_type not in models:
        return jsonify({'detail': 'Invalid model type'}), 400

    # validate if all mandatory arguments are sent
    missing_list = [item for item in models[model_type]['mandatory']['args'] if item not in request_data]
    if len(missing_list) != 0:
        return jsonify({'detail': 'Missing mandatory arguments', 'missing_args': missing_list}), 400

    # validate types of sent arguments
    invalid_type_list = \
        [
            {
                'arg': models[model_type]['mandatory']['args'][index],
                'sent_type': type(request_data[models[model_type]['mandatory']['args'][index]]).__name__,
                'expected_type': models[model_type]['mandatory']['types'][index].__name__
            }
            for index in range(len(models[model_type]['mandatory']['args']))
            if models[model_type]['mandatory']['types'][index] is not list
               and type(request_data[models[model_type]['mandatory']['args'][index]])
               != models[model_type]['mandatory']['types'][index]
        ] + \
        [
            {
                'argument': models[model_type]['optional']['args'][index],
                'sent_type': type(request_data[models[model_type]['optional']['args'][index]]).__name__,
                'expected_type': models[model_type]['optional']['types'][index].__name__
                if type(models[model_type]['optional']['types'][index]) != tuple
                else [atype.__name__ for atype in models[model_type]['optional']['types'][index]]
            }
            for index in range(len(models[model_type]['optional']['args']))
            if models[model_type]['optional']['args'][index] in request_data
               and request_data[models[model_type]['optional']['args'][index]] is not None
               and ((type(models[model_type]['optional']['types'][index]) != tuple
                     and type(request_data[models[model_type]['optional']['args'][index]])
                     != models[model_type]['optional']['types'][index])
                    or (type(models[model_type]['optional']['types'][index]) == tuple
                        and len([atype for atype in models[model_type]['optional']['types'][index]
                                 if type(request_data[models[model_type]['optional']['args'][index]]) == atype]) == 0))
        ]

    if len(invalid_type_list) != 0:
        return jsonify({'detail': 'Invalid types for arguments.', 'invalid_args': invalid_type_list}), 400

    if not check_file(get_data_dir(user_id=user_id, data_id=data_id)[0]):
        return jsonify({'detail': 'Data file does not exist.'}), 404

    user_model_dir = os.path.join(MODEL_DIR, f"{user_id}")
    if not os.path.exists(user_model_dir):
        os.makedirs(user_model_dir)

    # build parameters for ML function
    model_args = {
        'user_id': user_id,
        'data_id': data_id,
        'model_id': model_id
    }
    for item in models[model_type]['mandatory']['args']:
        model_args[item] = request_data[item]
    for index in range(len(models[model_type]['optional']['args'])):
        item = models[model_type]['optional']['args'][index]
        model_args[item] = models[model_type]['optional']['default_values'][index] if item not in request_data else \
            request_data[item]

    # determine the training type, regression or classification
    if 'type' in models[model_type]:
        model_args['train_type'] = models[model_type]['type']

    # start training
    p = Process(target=models[model_type]['function'], kwargs=model_args)
    p.start()

    return jsonify({'detail': 'Started training'}), 202


@app.route('/upload/<file_extension>/<int:data_id>', methods=["POST"])
def upload(file_extension, data_id):
    token = DataServer.extract_token(request)

    # check if user sent token
    if token is None:
        return jsonify({"detail": "Authentication credentials were not provided."}), 401

    # send a request to the data server to authenticate the user via the token
    user = DataServer.auth_user(token)
    # none is returned if the token is invalid
    if user is None:
        return jsonify({"detail": "Invalid token."}), 401

    # get data information from the data server
    user_data = DataServer.get_user_data(user_id=user['user_id'], data_id=data_id)
    if user_data is None:
        return jsonify({"detail": "The data specified was not found."}), 404

    # check if the user owns the data to be uploaded
    if user_data['owner'] != user['user_id']:
        return jsonify({"detail": "You do not have permission to perform this action."}), 403

    if file_extension not in file_extensions[user_data['type']]:
        return jsonify({"detail": "This data set type does not support this file extension."}), 400

    response = {
        'type': user_data['type']
    }

    # create directories for the user if it doesn't exist
    user_data_dir = os.path.join(DATA_DIR, f"{user['user_id']}")
    if not os.path.exists(user_data_dir):
        os.makedirs(user_data_dir)
    user_model_dir = os.path.join(MODEL_DIR, f"{user['user_id']}")
    if not os.path.exists(user_model_dir):
        os.makedirs(user_model_dir)

    # file is sent in request body, open a temp file and start writing to it
    temp_file_dir = os.path.join(DATA_DIR, f"{user['user_id']}", f'temp.{file_extension}')
    with open(temp_file_dir, "wb") as file:
        file.write(request.data)

    # try to open the file and get some information about it before overwriting the existing file
    try:
        response['columns'] = get_columns(temp_file_dir, file_extension)
    except (UnicodeDecodeError, EmptyDataError, Exception):
        os.remove(temp_file_dir)
        return jsonify({'detail': f"Invalid {user_data['type']} file"}), 415

    # if a data file already exists, remove it first
    file_dir = os.path.join(DATA_DIR, f"{user['user_id']}", f'{user_data["id"]}.{file_extension}')
    if os.path.exists(file_dir) and os.path.isfile(file_dir):
        os.remove(file_dir)
    # rename temp file to the new file name
    os.rename(temp_file_dir, file_dir)

    # return status code CREATED
    return jsonify(response), 201


@app.route('/info/m/', methods=["GET"])
def model_info():
    # validate if the request is JSON or not
    if not request.is_json:
        return jsonify({'detail': 'Invalid format'}), 400

    # check if the data server is the one requesting by checking the token
    if not DataServer.check_data_token(request):
        return jsonify({'detail': 'Unauthorized'}), 401

    # validate main request arguments
    request_data = request.get_json()
    missing_args = [item[0] for item in GET_MODEL_INFO_ARGS if item[0] not in request_data]
    if len(missing_args) == 1 and missing_args[0] == 'model_id':
        pass
    elif len(missing_args) != 0:
        return jsonify({'detail': 'Missing arguments', 'missing_args': missing_args}), 400
    invalid_args = \
        [
            {
                'arg': GET_MODEL_INFO_ARGS[index][0],
                'sent_type': type(request_data[GET_MODEL_INFO_ARGS[index][0]]).__name__,
                'expected_type': GET_MODEL_INFO_ARGS[index][1].__name__
            }
            for index in range(len(GET_MODEL_INFO_ARGS))
            if type(request_data[GET_MODEL_INFO_ARGS[index][0]])
               != GET_MODEL_INFO_ARGS[index][1]
        ]
    if len(invalid_args) != 0:
        return jsonify({'detail': 'Invalid types for arguments.', 'invalid_args': invalid_args}), 400

    user_id = request_data['user_id']
    model_id = request_data['model_id']

    # get data information from the data server
    user_model = DataServer.get_user_model(user_id=user_id, model_id=model_id)
    if user_model is None:
        return jsonify({"detail": "The model specified was not found."}), 404

    # check if the user owns the data to be uploaded
    if user_model['owner'] != user_id:
        return jsonify({"detail": "The model specified does not belong to the user."}), 403

    user_model_dir = os.path.join(MODEL_DIR, f"{user_id}")
    if not os.path.exists(user_model_dir):
        return jsonify({'detail': 'The model has never been trained before.'}), 404

    if not check_file(get_model_dir(user_id=user_id, model_id=model_id)):
        return jsonify({'detail': 'The model has never been trained before.'}), 404

    if not check_file(get_model_info_dir(user_id=user_id, model_id=model_id)):
        return jsonify({'detail': 'The model has never been trained before.'}), 404

    model_info_dir = get_model_info_dir(user_id=user_id, model_id=model_id)
    model_info_file = open(model_info_dir, mode='r')
    model_info_text = model_info_file.read()
    model_info_file.close()

    return model_info_text, 200


@app.route('/info/d/', methods=["GET"])
def data_info():
    # validate if the request is JSON or not
    if not request.is_json:
        return jsonify({'detail': 'Invalid format'}), 400

    # check if the data server is the one requesting by checking the token
    if not DataServer.check_data_token(request):
        return jsonify({'detail': 'Unauthorized'}), 401

    # validate main request arguments
    request_data = request.get_json()
    missing_args = [item[0] for item in GET_DATA_INFO_ARGS if item[0] not in request_data]
    if len(missing_args) == 1 and missing_args[0] == 'data_id':
        pass
    elif len(missing_args) != 0:
        return jsonify({'detail': 'Missing arguments', 'missing_args': missing_args}), 400
    invalid_args = \
        [
            {
                'arg': GET_DATA_INFO_ARGS[index][0],
                'sent_type': type(request_data[GET_DATA_INFO_ARGS[index][0]]).__name__,
                'expected_type': GET_DATA_INFO_ARGS[index][1].__name__
            }
            for index in range(len(GET_DATA_INFO_ARGS))
            if type(request_data[GET_DATA_INFO_ARGS[index][0]])
               != GET_DATA_INFO_ARGS[index][1]
        ]
    if len(invalid_args) != 0:
        return jsonify({'detail': 'Invalid types for arguments.', 'invalid_args': invalid_args}), 400

    user_id = request_data['user_id']
    data_id = request_data['data_id']

    # get data information from the data server
    user_data = DataServer.get_user_data(user_id=user_id, data_id=data_id)
    if user_data is None:
        return jsonify({"detail": "The data set specified was not found."}), 404

    # check if the user owns the data to be uploaded
    if user_data['owner'] != user_id:
        return jsonify({"detail": "The data specified does not belong to the user"}), 403

    response = {
        'type': user_data['type']
    }

    # check if the data file exists
    filename, file_extension = get_data_dir(user_id=user_id, data_id=data_id)
    if filename is None:
        return jsonify({'detail': "File for requested data set not found"}), 404
    file_extension = file_extension[1:]
    # file_dir = os.path.join(DATA_DIR, f"{user_id}", f'{user_data["id"]}.{file_extension}')
    # if not (os.path.exists(file_dir) and os.path.isfile(file_dir)):
    #     return jsonify({'detail': "File for requested data set not found"}), 404

    # get columns of data to return to the user
    try:
        response['columns'] = get_columns(filename, file_extension)
    except (UnicodeDecodeError, EmptyDataError):
        return jsonify({'detail': f"Invalid {user_data['type']} file"}), 415

    return response, 200


@app.route('/download/m/<model_id>', methods=["GET"])
def download_model(model_id):
    token = DataServer.extract_token(request)

    # check if user sent token
    if token is None:
        return jsonify({"detail": "Authentication credentials were not provided."}), 401

    # send a request to the data server to authenticate the user via the token
    user = DataServer.auth_user(token)
    # none is returned if the token is invalid
    if user is None:
        return jsonify({"detail": "Invalid token."}), 401

    # get data information from the data server
    user_model = DataServer.get_user_model(user_id=user['user_id'], model_id=model_id)
    if user_model is None:
        return jsonify({"detail": "The model specified was not found."}), 404

    # check if the user owns the data to be uploaded
    if user_model['owner'] != user['user_id']:
        return jsonify({"detail": "You do not have permission to perform this action."}), 403

    user_id = user['user_id']
    model_name = user_model['name']

    # check if the file for th model exists
    user_model_dir = os.path.join(MODEL_DIR, f"{user_id}")
    if not os.path.exists(user_model_dir):
        return jsonify({'detail': 'Model was never trained before.'}), 404

    if not check_file(get_model_dir(user_id=user_id, model_id=model_id)):
        return jsonify({'detail': 'Model was never trained before.'}), 404

    return Response(
        response=stream_with_context(read_file_chunks(get_model_dir(user_id=user_id, model_id=model_id))),
        status=200,
        headers={
            'Content-Disposition': f'attachment; filename={model_name}.pickle'
        },
        mimetype='application/octet-stream'
    )


@app.route('/predict/<model_id>', methods=["POST"])
def predict(model_id):
    token = DataServer.extract_token(request)

    # check if user sent token
    if token is None:
        return jsonify({"detail": "Authentication credentials were not provided."}), 401

    # send a request to the data server to authenticate the user via the token
    user = DataServer.auth_user(token)
    # none is returned if the token is invalid
    if user is None:
        return jsonify({"detail": "Invalid token."}), 401

    user_id = user['user_id']
    # get data information from the data server
    user_model = DataServer.get_user_model(user_id=user_id, model_id=model_id)
    if user_model is None:
        return jsonify({"detail": "The model specified was not found."}), 404

    # check if the user owns the data to be uploaded
    if user_model['owner'] != user['user_id']:
        return jsonify({"detail": "You do not have permission to perform this action."}), 403

    # check if the file for the model exists
    user_model_dir = os.path.join(MODEL_DIR, f"{user_id}")
    if not os.path.exists(user_model_dir):
        return jsonify({'detail': 'Model was never trained before.'}), 404

    if not check_file(get_model_dir(user_id=user_id, model_id=model_id)):
        return jsonify({'detail': 'Model was never trained before.'}), 404

    if not check_file(get_model_info_dir(user_id=user_id, model_id=model_id)):
        return jsonify({'detail': 'Model was never trained before.'}), 404

    # create directories for the user if it doesn't exist
    user_prediction_dir = os.path.join(PREDICT_DIR, f"{user['user_id']}")
    if not os.path.exists(user_prediction_dir):
        os.makedirs(user_prediction_dir)

    model_info_dir = get_model_info_dir(user_id=user_id, model_id=model_id)
    model_info_file = open(model_info_dir, mode='r')
    model_info_text = model_info_file.read()
    model_info_file.close()
    model_info = json.loads(model_info_text)

    dataset_type = model_info['dataset_info']['type']
    dataset_column_info = model_info['dataset_info']['columns']

    # file is sent in request body, open a temp file and start writing to it
    temp_file_dir = os.path.join(PREDICT_DIR, f"{user['user_id']}", f'temp.{dataset_type}')
    with open(temp_file_dir, "wb") as file:
        file.write(request.data)

    # try to open the file and get some information about it before overwriting the existing file
    try:
        prediction_dataset_column_info = get_columns(temp_file_dir, dataset_type)
    except (UnicodeDecodeError, EmptyDataError):
        os.remove(temp_file_dir)
        return jsonify({'detail': f"Invalid {dataset_type} file."}), 415

    # check columns of the prediction data compared to the training data
    invalid_columns = []
    dataset_column_info_dict = {column['name']: column for column in dataset_column_info}
    for column in prediction_dataset_column_info:
        if column['name'] in dataset_column_info_dict:
            if column['type'] != dataset_column_info_dict[column['name']]['type']:
                invalid_columns.append({
                    'detail': 'Unexpected type',
                    'name': column['name'],
                    'expected_type': dataset_column_info_dict[column['name']]['type']
                })
        else:
            if column['name'] not in model_info['to_drop'] and column['name'] != model_info['y_col']:
                invalid_columns.append({
                    'detail': 'Missing column that was not dropped during training',
                    'name': column['name'],
                })
    if len(invalid_columns) != 0:
        return jsonify({'detail': 'The columns of the prediction file do not match the columns used for training',
                        'invalid_columns': invalid_columns}), 400

    to_drop = [col_name for col_name in model_info['to_drop'] if col_name in dataset_column_info_dict]

    from predict import predict as predict_data
    predict_data(user_id=user_id, model_id=model_id, to_drop=to_drop,
                 predict_data_dir=temp_file_dir, model_info=model_info,)

    # return status code CREATED
    return jsonify({
        'detail': 'Prediction done. You can access the data from the given endpoint.',
        'endpoint': f'/download/p/{model_id}'
    }), 201


@app.route('/download/p/<model_id>', methods=["GET"])
def download_prediction(model_id):
    token = DataServer.extract_token(request)

    # check if user sent token
    if token is None:
        return jsonify({"detail": "Authentication credentials were not provided."}), 401

    # send a request to the data server to authenticate the user via the token
    user = DataServer.auth_user(token)
    # none is returned if the token is invalid
    if user is None:
        return jsonify({"detail": "Invalid token."}), 401

    # get data information from the data server
    user_model = DataServer.get_user_model(user_id=user['user_id'], model_id=model_id)
    if user_model is None:
        return jsonify({"detail": "The model specified was not found."}), 404

    # check if the user owns the data to be uploaded
    if user_model['owner'] != user['user_id']:
        return jsonify({"detail": "You do not have permission to perform this action."}), 403

    user_id = user['user_id']
    model_name = user_model['name']

    user_model_dir = os.path.join(MODEL_DIR, f"{user_id}")
    if not os.path.exists(user_model_dir):
        return jsonify({'detail': 'No predictions were preformed on this model before.'}), 404

    if not check_file(get_model_dir(user_id=user_id, model_id=model_id)):
        return jsonify({'detail': 'No predictions were preformed on this model before.'}), 404

    if not check_file(get_model_info_dir(user_id=user_id, model_id=model_id)):
        return jsonify({'detail': 'No predictions were preformed on this model before.'}), 404

    model_info_dir = get_model_info_dir(user_id=user_id, model_id=model_id)
    model_info_file = open(model_info_dir, mode='r')
    model_info_text = model_info_file.read()
    model_info_file.close()
    model_info = json.loads(model_info_text)

    # check if the file for the prediction exists
    user_model_dir = os.path.join(PREDICT_DIR, f"{user_id}")
    if not os.path.exists(user_model_dir):
        return jsonify({'detail': 'No predictions were preformed on this model before'}), 404

    if not check_file(get_predict_dir(user_id=user_id, model_id=model_id,
                                      file_type=model_info['dataset_info']['type'])):
        return jsonify({'detail': 'No predictions were preformed on this model before'}), 404

    return Response(
        response=stream_with_context(
            read_file_chunks(get_predict_dir(user_id=user_id, model_id=model_id,
                                             file_type=model_info['dataset_info']['type']))),
        status=200,
        headers={
            'Content-Disposition': f'attachment; filename={model_name}.{model_info["dataset_info"]["type"]}'
        },
        mimetype='application/octet-stream'
    )


if __name__ == '__main__':
    app.run(debug=True)
