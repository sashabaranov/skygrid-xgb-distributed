#!/usr/bin/python
import threading
import sys
import subprocess


class wait_etcd_key(object):
    def __init__(self):
        self.process = None
        self.thread = None
        self.out = None

    def make_response(self, task, ip, port, key):
        return subprocess.check_output(['curl', '-L',
                                        ''.join(('http://', ip, ':', port, '/v2/keys/', task, '/', key))])

    def task(self, task, ip, port, key):
        self.process = subprocess.Popen(['curl', '-L',
                                        ''.join(('http://', ip, ':', port, '/v2/keys/', task, '/', key, '?wait=true'))],
                                        stdout=subprocess.PIPE)
        self.out = self.process.communicate()[0]

    def start(self, task, ip, port, key):
        self.thread = threading.Thread(None, self.task, None, (task, ip, port, key))
        self.thread.start()

    def wait(self):
        self.thread.join()
        return self.out

    def stop(self):
        if self.thread.is_alive():
            try:
                self.process.terminate()
            except:
                print 'exception'
            self.thread.join()


def is_error_response(response):
    print response
    print 'errorCode' in response.split('"')
    return 'errorCode' in response.split('"')


def main(argv):
    wait_task = wait_etcd_key()
    print wait_task.make_response(*argv)
    while True:
        wait_task.start(*argv)
        response = wait_task.make_response(*argv)
        if not is_error_response(response):
            wait_task.stop()
            return
        response = wait_task.wait()
        if not is_error_response(response):
            break

if __name__ == "__main__":
    main(sys.argv[1:])


