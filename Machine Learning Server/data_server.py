import requests


class DataServer:
    _data_server_ip = 'http://127.0.0.1:8000'
    data_server_token = None

    _data_server_username = 'ml'
    _data_server_password = 'xU+63(VnNm<Qsv#,'

    @staticmethod
    def data_server_login():
        response = requests.post(f'{DataServer._data_server_ip}/api/login/',
                                 json={'username': DataServer._data_server_username, 'password': DataServer._data_server_password})
        print(response.status_code)
        if response.status_code == 200:
            DataServer.data_server_token = response.json()['token']
            print(response.json()['token'])
            # return True
        return response

    @staticmethod
    def extract_token(request):
        # check if user sent authorization header
        if 'Authorization' not in request.headers:
            return None

        auth = request.headers['Authorization']
        # if invalid auth content
        if not auth.startswith('Bearer '):
            return None

        # extract token from auth header
        _, _, token = auth.partition(' ')
        return token

    @staticmethod
    def check_data_token(request):
        if DataServer.data_server_token is None:
            DataServer.data_server_login()
        token = DataServer.extract_token(request)
        if token is None or token != DataServer.data_server_token:
            return False
        return True

    @staticmethod
    def auth_user(token: str):
        if DataServer.data_server_token is None:
            DataServer.data_server_login()
        response = requests.get(f'{DataServer._data_server_ip}/api/ml/user-token/{token}/',
                                headers={'Authorization': f'Bearer {DataServer.data_server_token}'})
        if response.status_code == 200:
            return response.json()
        return None

    @staticmethod
    def create_user_data(user_id: int, file_type: str):
        if DataServer.data_server_token is None:
            DataServer.data_server_login()
        response = requests.post(f'{DataServer._data_server_ip}/api/ml/user-data/',
                                 json={'type': file_type, 'owner': user_id},
                                 headers={'Authorization': f'Bearer {DataServer.data_server_token}'})
        if response.status_code == 201:  # CREATED
            return response.json()
        return None

    @staticmethod
    def get_user_data(user_id: int, data_id: int):
        if DataServer.data_server_token is None:
            DataServer.data_server_login()
        response = requests.get(f'{DataServer._data_server_ip}/api/ml/user-data/{data_id}/',
                                headers={'Authorization': f'Bearer {DataServer.data_server_token}'})
        if response.status_code == 200:
            print(response.json()['owner'])
            return response.json()
        return None

    @staticmethod
    def get_user_model(user_id: int, model_id: int):
        if DataServer.data_server_token is None:
            DataServer.data_server_login()
        response = requests.get(f'{DataServer._data_server_ip}/api/ml/user-model/{model_id}/',
                                headers={'Authorization': f'Bearer {DataServer.data_server_token}'})
        if response.status_code == 200:
            print(response.json()['owner'])
            return response.json()
        return None

    @staticmethod
    def notify_server(model_id: int, status: str, extra: dict):
        if DataServer.data_server_token is None:
            DataServer.data_server_login()
        response = requests.post(f'{DataServer._data_server_ip}/api/ml/notify/{model_id}/',
                                 json={'status': status, 'extra': extra},
                                 headers={'Authorization': f'Bearer {DataServer.data_server_token}'})
        return response.json()
