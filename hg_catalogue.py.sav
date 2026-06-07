from datetime import datetime
import glob
from openpyxl import Workbook
from openpyxl.utils.dataframe import dataframe_to_rows
import pandas as pd
import re

def create_catalogue(scan_path, cat_path):

    df_scan = scan_tree(scan_path)
    df = add_cat_columns(df_scan)

    result = write_catalogue(df, cat_path)

def scan_tree(head):


    path = f"{head}/**/*.dat"
    pathnames = glob.glob("./**/*.dat", root_dir="../not_in_repo/generated_dirs/group/datashare")
    filenames  = [re.search(r"([^/]+)\.dat$", pn).group(1) for pn in pathnames]
    dirnames = [re.search(r"(.*)/[^/]+$", pn).group(1) for pn in pathnames]
   
    df = pd.DataFrame(data={
        "Dir name": dirnames,
        "File name": filenames,
        "Path name": pathnames
    })
    return df

def add_cat_columns(df):
    # Extract date from filename
    df['Date'] = pd.to_datetime(
        df['File name'].str.extract(r"_(\d{8})_")[0]
        ).dt.date
    
    # Lookup species from filename
    sp_lookup = {
        "hu": "human",
        "mu": "mouse"
    }
    sp_code = df["File name"].str.extract(r"_([^_]+)_\d{8}_")
    df['Species'] = sp_code.apply(
        lambda str: [sp_lookup[val] if val in sp_lookup else val for val in str ]
        )
    
    # Move pathnames to last column
    df.insert(len(df.columns)-1, "Path name", df.pop("Path name"))
    
    return df


def write_catalogue(df, cat_path):
    wb = Workbook()
    ws = wb.active

    for r in dataframe_to_rows(df, index=True, header=True):
        ws.append(r)
    ws.delete_rows(2)
    for cell in ws["A"] + ws[1]:
        cell.style = "Pandas"

    ws.column_dimensions['C'].width = 27
    ws.column_dimensions['D'].width = 14
    ws.auto_filter.ref=ws.dimensions

    wb.save(filename=cat_path)
    

def shortdt():
    dt = datetime.now().strftime("%Y%m%dT%H%H%M")
    return dt