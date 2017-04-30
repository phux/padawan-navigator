import neovim
from os import path
from urllib.error import URLError
from socket import timeout
import sys
import re
from padawan_navigator import server  # noqa

@neovim.plugin
class PadawanNavigatorPlugin(object):
    def __init__(self, vim):
        self.vim = vim
        self.current = vim.current
        server_addr = self.vim.eval(
            'g:padawan_navigator#server_addr')
        server_command = self.vim.eval(
            'g:padawan_navigator#server_command')
        log_file = self.vim.eval(
            'g:padawan_navigator#log_file')
        self.server = server.Server(server_addr, server_command, log_file)

    @neovim.function("PadawanGetParents", sync=True)
    def padawangetparentclass_handler(self, args):
        file_path = self.current.buffer.name
        current_path = self.get_project_root(file_path)

        [line_num, column_num] = self.current.window.cursor

        contents = "\n".join(self.current.buffer)

        params = {
                'filepath': file_path.replace(current_path, ""),
                'line': line_num,
                'column': column_num,
                'path': current_path,
                'navigationtype': 'find-parents'
                }
        result = self.do_request('navigate', params, contents)

        if not result or 'parents' not in result or not result['parents']:
            self.vim.command("echom 'no parents found'")
        else:
            self.vim.command("call padawan_navigator#PopulateList(%s)" % result['parents'])

    @neovim.function("PadawanGetImplementations", sync=True)
    def padawangetimplementations_handler(self, args):
        file_path = self.current.buffer.name
        current_path = self.get_project_root(file_path)

        [line_num, column_num] = self.current.window.cursor

        contents = "\n".join(self.current.buffer)

        params = {
                'filepath': file_path.replace(current_path, ""),
                'line': line_num,
                'column': column_num,
                'path': current_path,
                'navigationtype': 'find-implementations'
                }
        result = self.do_request('navigate', params, contents)

        if not result or 'children' not in result or not result['children']:
            self.vim.command("echom 'no implementations found'")
        else:
            self.vim.command("call padawan_navigator#PopulateList(%s)" % result['children'])


    def do_request(self, command, params, data=''):
        try:
            return self.server.sendRequest(command, params, data)
        except URLError:
            if self.vim.eval('g:padawan_navigator#server_autostart') == 1:
                self.server.start()
                self.vim.command(
                    "echom 'Padawan.php server started automatically'")
            else:
                self.vim.command("echom 'Padawan.php is not running'")
        except timeout:
            self.vim.command("echom 'Connection to padawan.php timed out'")
        except ValueError as error:
            self.vim.command("echom 'Padawan.php error: {}'".format(error))
        # any other error can bouble to deoplete
        return False

    def get_project_root(self, file_path):
        current_path = path.dirname(file_path)
        while current_path != '/' and not path.exists(
                path.join(current_path, 'composer.json')
        ):
            current_path = path.dirname(current_path)

        if current_path == '/':
            current_path = path.dirname(file_path)

        return current_path
