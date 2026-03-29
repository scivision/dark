function plan = buildfile

plan = buildplan(localfunctions);

plan("test") = matlab.buildtool.tasks.TestTask("test/");
end

function checkTask(context)
root = context.Plan.RootFolder;

c = codeIssues(root, IncludeSubfolders=true);

if isempty(c.Issues)
  fprintf('%d files checked OK with %s under %s\n', numel(c.Files), c.Release, root)
else
  disp(c.Issues)
  error("Errors found in " + join(c.Issues.Location, newline))
end

end

function installTask(~)
assert(install_font(), "install font failed")
end
