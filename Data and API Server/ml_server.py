import requests


_ml_server_ip = 'http://127.0.0.1:5000'


def train_model(user_id: int,
                data_id: int,
                model_id: int,
                token: str,
                model_type: str,
                args: dict):
    args['user_id'] = user_id
    args['model_id'] = model_id
    args['data_id'] = data_id
    args['model_type'] = model_type
    response = requests.post(f'{_ml_server_ip}/train/',
                             headers={'Authorization': f'Bearer {token}'},
                             json=args)
    return response


def get_data_info(user_id: int,
                  data_id: int,
                  token: str,):
    response = requests.get(f'{_ml_server_ip}/info/d/',
                            headers={'Authorization': f'Bearer {token}'},
                            json={
                                'user_id': user_id,
                                'data_id': data_id
                            })
    return response


def get_model_info(user_id: int,
                   model_id: int,
                   token: str,):
    response = requests.get(f'{_ml_server_ip}/info/m/',
                            headers={'Authorization': f'Bearer {token}'},
                            json={
                                'user_id': user_id,
                                'model_id': model_id,
                            })
    return response
