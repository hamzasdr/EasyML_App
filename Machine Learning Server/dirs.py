import os
from os import listdir
from os.path import splitext, isfile, join, exists

DATA_DIR = os.path.join('.', 'data')
MODEL_DIR = os.path.join('.', 'model')
PREDICT_DIR = os.path.join('.', 'predict')
CHUNK_SIZE = 8192


def check_file(path: str):
    return os.path.exists(path) and os.path.isfile(path)


def get_data_dir(user_id: int, data_id: int):
    path = join(DATA_DIR, f'{user_id}')
    if not exists(path):
        return None, None
    files = [splitext(f) for f in listdir(path) if isfile(join(path, f))]
    try:
        file_extension = [f[1] for f in files if f[0] == f'{data_id}'][0]
    except IndexError:
        return None, None
    filename = os.path.join(DATA_DIR, f'{user_id}', f'{data_id}{file_extension}')
    return filename, file_extension


def get_model_dir(user_id: int, model_id: int):
    return os.path.join(MODEL_DIR, f'{user_id}', f'{model_id}.pickle')


def get_model_info_dir(user_id: int, model_id: int):
    return os.path.join(MODEL_DIR, f'{user_id}', f'{model_id}.json')


def get_predict_dir(user_id: int, model_id: int, file_type: str):
    return os.path.join(PREDICT_DIR, f'{user_id}', f'{model_id}.{file_type}')


def read_file_chunks(path):
    with open(path, 'rb') as fd:
        while 1:
            buf = fd.read(CHUNK_SIZE)
            if buf:
                yield buf
            else:
                break
