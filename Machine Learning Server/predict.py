from pandas import DataFrame

from data_files import file_extensions
from dirs import get_model_dir, get_predict_dir
import pickle
import pandas as pd
from sklearn import preprocessing


def predict(user_id: int,
            model_id: int,
            to_drop: list,
            predict_data_dir: str,
            model_info: dict, ):

    model_dir = get_model_dir(user_id=user_id, model_id=model_id)
    print(model_dir)
    trained_model_file = open(model_dir, 'rb')
    model_data = pickle.load(trained_model_file, fix_imports=True)
    trained_model_file.close()
    file_type = model_info['dataset_info']['type']
    if file_type in file_extensions['csv']:
        df = pd.read_csv(predict_data_dir)
    elif file_type in file_extensions['json']:
        df = pd.read_json(predict_data_dir, orient='split')
    elif file_type in file_extensions['excel']:
        excel = pd.ExcelFile(predict_data_dir)
        df = pd.read_excel(predict_data_dir, excel.sheet_names[0])
    else:
        raise Exception('Unsupported file type')

    to_drop = [] if to_drop is None else to_drop

    df = df.drop(columns=[col for col in to_drop if col in df])

    label_encodes = model_data['label_encoders']
    for column in label_encodes:
        le = label_encodes[column]
        df[column] = le.fit_transform(df[column])

    y_col = model_info['y_col']
    if y_col in df:
        x = df.loc[:, df.columns != y_col]
    else:
        x = df

    normalize_scaler = model_data['normalize_scaler']

    model = model_data['model']

    if normalize_scaler is not None:
        y = DataFrame(data=model.predict(normalize_scaler.transform(x)), columns=[y_col])
    else:
        y = DataFrame(data=model.predict(x), columns=[y_col])

    predict_dir = get_predict_dir(user_id=user_id, model_id=model_id, file_type=file_type)

    if file_type in file_extensions['csv']:
        y.to_csv(predict_dir)
    elif file_type in file_extensions['json']:
        y.to_json(predict_dir, orient='split')
    elif file_type in file_extensions['excel']:
        y.to_excel(predict_dir, sheet_name='Sheet1')

