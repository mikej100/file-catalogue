import pytest

def test_fileset_0(fileset_0):
    assert fileset_0.is_dir()
    assert (fileset_0 / "file1.txt").is_file()
    assert (fileset_0 / "file2.txt").is_file()