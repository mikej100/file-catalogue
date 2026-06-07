import pytest

def test_fileset_1(fileset_1):
    test_dir = fileset_1
    assert test_dir.is_dir()

    for user in ["anna_a", "brian_b", "charlie_c"]:
        user_dir = test_dir / user
        assert user_dir.is_dir()
        
        if user == "charlie_c":
            assert not any(user_dir.iterdir()), f"{user} directory should be empty"
        else:
            for i in range(1, 4):
                file_name = f"seq1_{'hu' if user == 'anna_a' else 'mu'}_2024022{i}_lt{i}_run001.dat"
                file_path = user_dir / file_name
                assert file_path.is_file(), f"{file_name} should exist in {user} directory"