classdef (SharedTestFixtures={ matlab.unittest.fixtures.PathFixture(fileparts(fileparts(mfilename('fullpath'))))}) ...
    TestDark < matlab.unittest.TestCase

properties (Constant)
Tol = 1e-12;
Black = [0 0 0];
White = [1 1 1];
Peach = [0.9290 0.6940 0.1250];
Blue = [0 0 1];
interactive = false
end


methods (Test)
function lineLegendAndTextStyling(tc)
fig = figure(Visible=tc.interactive);
tc.addTeardown(@close, fig)


plot([(1:10)' (10:-1:1)'],'o-');
grid on
legend('this','that')
xlabel('blivit')
ylabel('barvid')
title('This and That')
th = text(4.5, 8, 'hello world!');
dark()

ax = gca;
lgd = legend;

% Canvas and axes decoration colors should switch to dark mode.
tc.verifyEqual(ax.Color, tc.Black);
tc.verifyEqual(fig.Color, tc.Black);
tc.verifyEqual(ax.XColor, tc.White);
tc.verifyEqual(ax.YColor, tc.White);
tc.verifyEqual(ax.Title.Color, tc.White);
tc.verifyEqual(ax.XLabel.Color, tc.White);
tc.verifyEqual(ax.YLabel.Color, tc.White);

% User annotations and legend should also use dark-mode text colors.
tc.verifyEqual(th.Color, tc.White);
tc.verifyEqual(lgd.Color, tc.Black);
tc.verifyEqual(lgd.TextColor, tc.White);
tc.verifyEqual(lgd.EdgeColor, tc.White);

% Dark mode adjusts grid appearance as well.
tc.verifyEqual(ax.GridColor, tc.White);
tc.verifyEqual(ax.GridAlpha, 0.3, AbsTol=tc.Tol);
end

function barhStyling(tc)
fig = figure(Visible=tc.interactive);
tc.addTeardown(@close, fig)

barh([(1:10)' (10:-1:1)']);
grid on
legend('this','that')
dark()

ax = gca;
ch = ax.Children;
isBar = arrayfun(@(h) isa(h, 'matlab.graphics.chart.primitive.Bar'), ch);
barHandles = ch(isBar);

tc.verifyEqual(numel(barHandles), 2);
for k = 1:numel(barHandles)
  tc.verifyEqual(barHandles(k).FaceColorMode, 'manual');
  tc.verifyEqual(barHandles(k).EdgeColor, tc.White);
  tc.verifyEqual(barHandles(k).EdgeAlpha, 0.5, AbsTol=tc.Tol);
end
end

function customBarColors(tc)
fig = figure(Visible=tc.interactive);
tc.addTeardown(@close, fig)

bar([(1:10)' (10:-1:1)']);
dark('bp')

ax = gca;
ch = ax.Children;
isBar = arrayfun(@(h) isa(h, 'matlab.graphics.chart.primitive.Bar'), ch);
barHandles = ch(isBar);

tc.verifyEqual(numel(barHandles), 2);
barColors = zeros(numel(barHandles), 3);
for k = 1:numel(barHandles)
  barColors(k, :) = barHandles(k).FaceColor;
end

expected = [tc.Blue; tc.Peach];
for i = 1:size(expected, 1)
  deltas = max(abs(barColors - expected(i, :)), [], 2);
  tc.verifyTrue(any(deltas <= tc.Tol), 'Expected dark("bp") bar color missing.');
end
end

function plot3Styling(tc)
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
th = text(-0.75,-0.75,1,'hello world!');
dark()

ax = gca;
tc.verifyEqual(ax.Color, tc.Black);
tc.verifyEqual(ax.XColor, tc.White);
tc.verifyEqual(ax.YColor, tc.White);
tc.verifyEqual(ax.ZColor, tc.White);
tc.verifyEqual(ax.Title.Color, tc.White);
tc.verifyEqual(ax.XLabel.Color, tc.White);
tc.verifyEqual(ax.YLabel.Color, tc.White);
tc.verifyEqual(ax.ZLabel.Color, tc.White);
tc.verifyEqual(th.Color, tc.White);
end

function surfOverImagescStyling(tc)
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

ax = gca;
tc.verifyEqual(ax.Color, tc.Black);
tc.verifyEqual(ax.XColor, tc.White);
tc.verifyEqual(ax.YColor, tc.White);
tc.verifyEqual(ax.ZColor, tc.White);
tc.verifyEqual(ax.Title.Color, tc.White);
tc.verifyEqual(ax.XLabel.Color, tc.White);
tc.verifyEqual(ax.YLabel.Color, tc.White);
tc.verifyEqual(ax.ZLabel.Color, tc.White);

cb = ax.Colorbar;
tc.verifyNotEmpty(cb);
tc.verifyEqual(cb.Color, tc.White);

ch = ax.Children;
tc.verifyTrue(any(arrayfun(@(h) isa(h, 'matlab.graphics.chart.primitive.Surface'), ch)));
tc.verifyTrue(any(arrayfun(@(h) isa(h, 'matlab.graphics.primitive.Image'), ch)));
end
end
end
