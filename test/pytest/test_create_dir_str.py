import datetime
import os
import shutil

import hg_catalogue as hgc

# CCreate directory structure and files for development and test
# TODO - make this safer by creating -temp_test root, 

test_path = "../not_in_repo/test_temp_data/group/datashare"


def test_generate_test_directories():
    if not os.path.exists(test_path):   
        os.makedirs(test_path)

    shutil.rmtree(test_path)

    user_names = ["anna_a", "brian_b", "charlie_c"]
    
    user_files = {
        "anna_a": [
            "seq1_hu_20240220_lt1_run001",
            "seq1_hu_20240220_lt1_run002",
            "seq1_hu_20240220_lt1_run003",
            ],
        "brian_b": [
            "seq1_hu_20240222_lt1_run001",
            "seq1_mu_20240222_lt2_run001",
            "seq1_mu_20240222_lt3_run001",
            ],
        "charlie_c":[]
    }
    result = [ os.makedirs(os.path.join(test_path, u)) for u in user_names]

    def create_all_user_files(u_names):
        res = [create_one_user_files(u) for u in u_names]

    def create_one_user_files(user):
        res = [
            wr_file(os.path.join(test_path, user, f'{f}.dat'))
                for f in user_files[user]
                ]
    
    def wr_file(fpath):
        with open (fpath, "w") as f:
            f.write(f'timestamp: {shortdt()}')

    res = create_all_user_files(user_names)

# Generate short form of date text YYYMMDD for current date
def shortdt():
    dt = datetime.datetime.now().strftime("%Y%m%dT%H%H%M")
    return dt

def test_create_catalogue():
    cat_path = os.path.join(test_path,f"catalogue{shortdt()}.xlsx")
    scan_path = test_path
    hgc.create_catalogue(test_path, cat_path)