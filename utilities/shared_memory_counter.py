from multiprocessing import shared_memory
import struct
import logging

logger = logging.getLogger()

SHARED_MEMORY_NAME = 'request_counter'

def read_and_increment_shared_memory_counter():
    import fcntl
    import tempfile
    import os

    try:
        shm = shared_memory.SharedMemory(name=SHARED_MEMORY_NAME)

        # Use file-based lock for cross-process synchronization
        lock_file = os.path.join(tempfile.gettempdir(), 'request_counter.lock')

        with open(lock_file, 'w') as f:
            # This lock will be released in case of errors.
            fcntl.flock(f.fileno(), fcntl.LOCK_EX)
            # Reads 4 bytes from shared memory starting at position 0
            # Interprets those bytes as a signed integer
            # Returns the integer value
            current_count = struct.unpack_from('i', shm.buf, 0)[0]
            struct.pack_into('i', shm.buf, 0, current_count + 1)
            logger.info(f"Request count: {current_count + 1}")
    except FileNotFoundError:
        logger.error("Shared memory not found")


def init_request_counter():
    # Create shared memory for integer counter
    shm = shared_memory.SharedMemory(name=SHARED_MEMORY_NAME, create=True, size=4)

    # Write integer 0 to shared memory
    struct.pack_into('i', shm.buf, 0, 0)
