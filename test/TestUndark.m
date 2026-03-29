classdef (SharedTestFixtures={ matlab.unittest.fixtures.PathFixture(fileparts(fileparts(mfilename('fullpath'))))}) ...
    TestUndark < matlab.unittest.TestCase

properties (Constant)
Tol = 1e-12;
Black = [0 0 0];
White = [1 1 1];
FigureLightGray = 0.94 * [1 1 1];
GridGray = 0.15 * [1 1 1];
interactive = false
end

methods (Test)
function restoresLineLegendAndGrid(tc)
fig = figure(Visible=tc.interactive);
tc.addTeardown(@close, fig)

plot([(1:10)' (10:-1:1)'],'o-');
grid on
legend('this','that')
xlabel('blivit')
ylabel('barvid')
title('This and That')
text(4.5,8,'hello world!')
dark()
undark()

ax = gca;
lgd = legend;

tc.verifyEqual(ax.Color, tc.White);
tc.verifyEqual(fig.Color, tc.FigureLightGray, AbsTol=tc.Tol);
tc.verifyEqual(ax.XColor, tc.Black);
tc.verifyEqual(ax.YColor, tc.Black);
tc.verifyEqual(ax.Title.Color, tc.Black);
tc.verifyEqual(ax.XLabel.Color, tc.Black);
tc.verifyEqual(ax.YLabel.Color, tc.Black);

tc.verifyEqual(lgd.Color, tc.White);
tc.verifyEqual(lgd.TextColor, tc.Black);
tc.verifyEqual(lgd.EdgeColor, tc.Black);

tc.verifyEqual(ax.GridColor, tc.GridGray, AbsTol=tc.Tol);
tc.verifyEqual(ax.GridAlpha, 0.2, AbsTol=tc.Tol);
end

function restoresBarhStyling(tc)
fig = figure(Visible=tc.interactive);
tc.addTeardown(@close, fig)

barh([(1:10)' (10:-1:1)']);
grid on
legend('this','that')
dark()
undark()

ax = gca;
ch = ax.Children;
isBar = arrayfun(@(h) isa(h, 'matlab.graphics.chart.primitive.Bar'), ch);
barHandles = ch(isBar);

tc.verifyEqual(numel(barHandles), 2);
for k = 1:numel(barHandles)
  tc.verifyEqual(barHandles(k).FaceColorMode, 'manual');
  tc.verifyEqual(barHandles(k).EdgeColor, tc.Black);
  tc.verifyEqual(barHandles(k).EdgeAlpha, 1.0, AbsTol=tc.Tol);
end
end

function restoresPlot3Styling(tc)
fig = figure(Visible=tc.interactive);
tc.addTeardown(@close, fig)

t = 0:pi/50:10*pi;
st = sin(t);
ct = cos(t);
plot3(st, ct, t)
grid on
xlabel('X')
ylabel('Y')
zlabel('Z')
title('3-d plot')
text(-0.75,-0.75,1,'hello world!')
dark()
undark()

ax = gca;
tc.verifyEqual(ax.Color, tc.White);
tc.verifyEqual(ax.XColor, tc.Black);
tc.verifyEqual(ax.YColor, tc.Black);
tc.verifyEqual(ax.ZColor, tc.Black);
tc.verifyEqual(ax.Title.Color, tc.Black);
tc.verifyEqual(ax.XLabel.Color, tc.Black);
tc.verifyEqual(ax.YLabel.Color, tc.Black);
tc.verifyEqual(ax.ZLabel.Color, tc.Black);
end

function restoresSurfOverImagescAndColorbar(tc)
fig = figure(Visible=tc.interactive);
tc.addTeardown(@close, fig)

Z = 10 + peaks;
surf(Z)
hold on
imagesc(Z)
grid off
hold off
xlabel('X')
ylabel('Y')
zlabel('Z')
title('3-d plot on top of imagesc')
text(10,20,2,'hello world!')
colorbar
dark()
undark()

ax = gca;
tc.verifyEqual(ax.Color, tc.White);
tc.verifyEqual(ax.XColor, tc.Black);
tc.verifyEqual(ax.YColor, tc.Black);
tc.verifyEqual(ax.ZColor, tc.Black);

cb = ax.Colorbar;
tc.verifyNotEmpty(cb);
tc.verifyEqual(cb.Color, tc.GridGray, AbsTol=tc.Tol);

ch = ax.Children;
tc.verifyTrue(any(arrayfun(@(h) isa(h, 'matlab.graphics.chart.primitive.Surface'), ch)));
tc.verifyTrue(any(arrayfun(@(h) isa(h, 'matlab.graphics.primitive.Image'), ch)));
end
end
end
