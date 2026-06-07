import datetime
import pytest
import logging
from pathlib import Path

test_workspace = Path(__file__).parent.parent / "test_workspace"
mkdir = test_workspace.mkdir(exist_ok=True)

@pytest.fixture(scope="session", autouse=True)
def configure_test_logging():

    # Create log directory
    log_dir = Path(__file__).parent.parent / "test_workspace" / "logs"
    log_dir.mkdir(parents=True, exist_ok=True)  
    log_file = log_dir / "pytest.log"

    root_logger = logging.getLogger("")
    root_logger.setLevel(logging.DEBUG)

    #remove existing handlers
    root_logger.handlers.clear()

    # File handler - captures everything
    file_handler = logging.FileHandler(log_file, mode='w')  # 'w' to overwrite each session
    file_handler.setLevel(logging.DEBUG)
    file_formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    file_handler.setFormatter(file_formatter)
    root_logger.addHandler(file_handler)
    
    # Console handler - for pytest output (captured unless -s is used)
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)
    console_formatter = logging.Formatter('%(name)s - %(levelname)s - %(message)s')
    console_handler.setFormatter(console_formatter)
    root_logger.addHandler(console_handler)
    
    # Log the start of test session
    root_logger.info("=" * 70)
    root_logger.info("Starting pytest session")
    root_logger.info(f"Logging to: {log_file}")
    root_logger.info("=" * 70)
    
    yield
    
    # Log the end of test session
    root_logger.info("=" * 70)
    root_logger.info("Pytest session complete")
    root_logger.info("=" * 70)


@pytest.fixture
def fileset_0(test_path=test_workspace):
    # Create a tiny fileset to test the test framework.
    test_dir = test_path / "fileset_0"
    test_dir.mkdir(exist_ok=True)
    
    # Create some test files
    file1 = test_dir / "file1.txt"
    file2 = test_dir / "file2.txt"
    file1.write_text("This is file 1.")
    file2.write_text("This is file 2.")
    
    return test_dir

@pytest.fixture
def fileset_1(test_path=test_workspace):
    # Create a temporary directory for the test
    test_dir = test_path / "fileset_1"
    test_dir.mkdir(exist_ok=True)
    

    # shutil.rmtree(test_path)

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
    result = [ (test_dir / u).mkdir(exist_ok=True) for u in user_names]

    def create_all_user_files(u_names):
        res = [create_one_user_files(u) for u in u_names]

    def create_one_user_files(user):
        res = [
            wr_file(test_dir / user / f'{f}.dat')
                for f in user_files[user]
                ]
    
    def wr_file(fpath):
        with open (fpath, "w") as f:
            f.write(f'timestamp: {shortdt()}')

    res = create_all_user_files(user_names)

    return test_dir 

# Generate short form of date text YYYMMDD for current date
def shortdt():
    dt = datetime.datetime.now().strftime("%Y%m%dT%H%H%M")
    return dt