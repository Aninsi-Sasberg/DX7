import os, random


def generate_checksum(data):
    sum = 0

    for byte in data:
        sum += byte
        if sum > 127:
            sum = sum - 128
            print(sum)

    sum = 128 - sum

    print(sum)

    return int.to_bytes(sum, 1, "big")


def trim_end(data):
    if len(data) > 4096:
        data = data[: 4096 - len(data)]


def remove_midi(data):
    return b"".join([int.to_bytes(byte % 128) for byte in data])


def bytes_to_int_list(data):
    return [byte for byte in data]


def int_list_to_bytes(data):
    return b"".join([int.to_bytes(byte) for byte in data])


def shuffle_bytes(data):
    return int_list_to_bytes(random.sample(bytes_to_int_list(data), len(data)))


def read_file(path):
    with open(path, mode="rb") as syx:
        return syx.read()


def write_file(path, header, data, checkSum, end):
    with open(path, mode="wb") as new:
        new.write(header + data + checkSum + end)


def main():
    mode = 0
    size_data = 4096
    path_in = "rom1a.syx"
    path_out = "new.syx"
    header = b"\xf0\x43\x00\x09\x20\x00"
    end = b"\xf7\x0a"

    match mode:
        # read and shuffle data
        case 0:
            contents = read_file(path_in)
            data = contents[6:-3]

            data = shuffle_bytes(data)

            data = remove_midi(data)
            checkSum = generate_checksum(data)
            write_file(path_out, header, data, checkSum, end)

        # generate random data
        case 1:
            data = os.urandom(size_data)

            data = remove_midi(data)
            checkSum = generate_checksum(data)
            write_file(path_out, header, data, checkSum, end)


if __name__ == "__main__":
    main()
