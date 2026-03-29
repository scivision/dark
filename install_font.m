function ok = install_font()

ok = any(ismember(listfonts(), 'xkcd Script'));
if ok
  disp('xkcd Script is already registered')
  return
end

xkcd_ttf = fullfile(fileparts([mfilename('fullpath') '.m']), 'xkcd-script.ttf');

if ispc()
  cmd = sprintf('pwsh -c "(New-Object -ComObject Shell.Application).Namespace(0x14).CopyHere(''%s'')"', xkcd_ttf);
  ok = ~system(cmd);
elseif ismac()
  disp('Install XKCD Script with Font Book')
  ok = ~system(sprintf('open -a "Font Book" %s', xkcd_ttf));
else
  fdir = '~/.local/share/fonts/';
  if ~exist(fdir, 'dir')
    mkdir(fdir);
  end
  fname = [fdir, 'xkcd-script.ttf'];

  if ~exist(fname, 'file')
    copyfile(xkcd_ttf, fname);
  end

  if exist(fname, 'file')
    system('fc-cache -f -y -v ~/.local/share/fonts/ 2> /dev/null');
    ok = ~system("fc-list -q 'xkcd Script'");
  end
end

inform_restart()

end % function

function y = isoctave()
y = exist('OCTAVE_VERSION', 'builtin') ~= 0;
end % function


function inform_restart()

  estr = sprintf('\n\n');
  estr = sprintf('%s    %s\n', estr,repmat('*',1,56));

  if isoctave()
    if strcmp(graphics_toolkit(),'gnuplot')
      estr = sprintf('%s    GNU Octave is configured to use gnuplot graphics which\n', estr);
      estr = sprintf('%s    is not compatible with HAND. Use the GNU Octave command\n', estr);
      estr = sprintf('%s    available_graphics_toolkits() and change to a different\n', estr);
      estr = sprintf('%s    toolkit with graphics_toolkit(new_toolkit_name).\n', estr);
      estr = sprintf('%s    See help graphics_toolkit for more information.\n', estr);
      error('%s', estr)
    else
      estr = sprintf('%s    Restart GNU OCtave to refresh font list.\n', estr);
    end
  else
    estr = sprintf('%s    Restart MATLAB to refresh font list.\n', estr);
  end

  estr = sprintf('%s    %s\n\n', estr,repmat('*',1,56));

  fprintf(estr);

end % function
