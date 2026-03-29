classdef (SharedTestFixtures={ matlab.unittest.fixtures.PathFixture(fileparts(fileparts(mfilename('fullpath'))))}) ...
    TestHand < matlab.unittest.TestCase

properties (Constant)
Tol = 1e-12;
CanvasRGB = [220 243 182] / 256;
ExpectedRG = [
0.6350 0.0780 0.1840;  % r
0.3023 0.6203 0.1812   % g
];
interactive = false
expectedFontName = 'xkcd Script'
fallbackFontName = {'xkcd Script', 'Segoe Print', 'Pacifico', 'Times'}
end


methods (Test)
function axesAndLabelColors(tc)
fig = figure(Visible=tc.interactive);
tc.addTeardown(@close, fig)

plot(1:10, 'LineWidth', 1.5)
grid('on')
xlabel('X')
ylabel('Y')
title('Y vs X')
hand()

ax = gca;
xt = ax.XLabel;
yt = ax.YLabel;
tt = ax.Title;

tc.verifyEqual(ax.Color, tc.CanvasRGB, AbsTol=tc.Tol)
tc.verifyEqual(ax.XColor, [0 0 0])
tc.verifyEqual(ax.YColor, [0 0 0])
tc.verifyEqual(tt.Color, [0 0 0])
tc.verifyEqual(xt.Color, [0 0 0])
tc.verifyEqual(yt.Color, [0 0 0])
end

function fontProperties(tc)
import matlab.unittest.constraints.IsEqualTo
import matlab.unittest.constraints.IsSubsetOf
fig = figure(Visible=tc.interactive);
tc.addTeardown(@close, fig)

plot(1:10);
xlabel('X')
ylabel('Y')
title('Font Check')
hand()

ax = gca;
if getenv('CI') == "true"
  tc.verifyThat({ax.FontName}, IsSubsetOf(tc.fallbackFontName))
else
  tc.verifyThat(ax.FontName, IsEqualTo(tc.expectedFontName))
end
tc.verifyEqual(ax.FontSize, 20)
tc.verifyThat(ax.FontAngle, IsEqualTo('normal') | IsEqualTo('italic'))
end

function lineColorsAndWidth(tc)
fig = figure(Visible=tc.interactive);
tc.addTeardown(@close, fig)

plot([(1:10)' (10:-1:1)'])
hand('rg')

ax = gca;
ch = ax.Children;
isLine = arrayfun(@(h) isa(h, 'matlab.graphics.chart.primitive.Line'), ch);
lineHandles = ch(isLine);

tc.verifyEqual(numel(lineHandles), 2)
for k = 1:numel(lineHandles)
    tc.verifyEqual(lineHandles(k).LineWidth, 3)
end

lineColors = zeros(numel(lineHandles), 3);
for k = 1:numel(lineHandles)
    lineColors(k, :) = lineHandles(k).Color;
end

for i = 1:size(tc.ExpectedRG, 1)
    deltas = max(abs(lineColors - tc.ExpectedRG(i, :)), [], 2);
    tc.verifyTrue(any(deltas <= tc.Tol), 'Expected line color missing after hand("rg").')
end
end

function legendStyling(tc)
fig = figure(Visible=tc.interactive);
tc.addTeardown(@close, fig)

plot([(1:10)' (10:-1:1)'])
legend('this', 'that')
hand()

lgd = legend;
tc.verifyEqual(lgd.Color, tc.CanvasRGB, 'AbsTol', tc.Tol)
tc.verifyEqual(lgd.TextColor, [0 0 0])
tc.verifyEqual(lgd.EdgeColor, [0 0 0])
end

function barhStyling(tc)
fig = figure(Visible=tc.interactive);
tc.addTeardown(@close, fig)

barh([(1:10)' (10:-1:1)'])
grid('on')
legend('this', 'that')
xlabel('blivit')
ylabel('barvid')
title('This and That')
hand()

ax = gca;
ch = ax.Children;
isBar = arrayfun(@(h) isa(h, 'matlab.graphics.chart.primitive.Bar'), ch);
barHandles = ch(isBar);

tc.verifyEqual(numel(barHandles), 2);
for k = 1:numel(barHandles)
  tc.verifyEqual(barHandles(k).FaceColorMode, 'manual')
  tc.verifyEqual(barHandles(k).EdgeColor, [0 0 0])
  tc.verifyEqual(barHandles(k).EdgeAlpha, 0.5)
end

lgd = legend;
tc.verifyEqual(lgd.Color, tc.CanvasRGB, AbsTol=tc.Tol)
tc.verifyEqual(lgd.TextColor, [0 0 0])
tc.verifyEqual(lgd.EdgeColor, [0 0 0])
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
hand()

ax = gca;

tc.verifyEqual(ax.Color, tc.CanvasRGB, AbsTol=tc.Tol)
tc.verifyEqual(ax.XColor, [0 0 0])
tc.verifyEqual(ax.YColor, [0 0 0])
tc.verifyEqual(ax.ZColor, [0 0 0])
tc.verifyEqual(ax.Title.Color, [0 0 0])
tc.verifyEqual(ax.XLabel.Color, [0 0 0])
tc.verifyEqual(ax.YLabel.Color, [0 0 0])
tc.verifyEqual(ax.ZLabel.Color, [0 0 0])

ch = ax.Children;
isLine = arrayfun(@(h) isa(h, 'matlab.graphics.chart.primitive.Line'), ch);
lineHandles = ch(isLine);
tc.verifyGreaterThanOrEqual(numel(lineHandles), 1);
for k = 1:numel(lineHandles)
  tc.verifyEqual(lineHandles(k).LineWidth, 3);
end
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
colorbar
hand()

ax = gca;
tt = ax.Title;
xt = ax.XLabel;
yt = ax.YLabel;
zt = ax.ZLabel;

tc.verifyEqual(ax.Color, tc.CanvasRGB, AbsTol=tc.Tol);
tc.verifyEqual(ax.XColor, [0 0 0]);
tc.verifyEqual(ax.YColor, [0 0 0]);
tc.verifyEqual(ax.ZColor, [0 0 0]);
tc.verifyEqual(tt.Color, [0 0 0]);
tc.verifyEqual(xt.Color, [0 0 0]);
tc.verifyEqual(yt.Color, [0 0 0]);
tc.verifyEqual(zt.Color, [0 0 0]);

cb = ax.Colorbar;
tc.verifyNotEmpty(cb);
tc.verifyEqual(cb.Color, [0 0 0]);

ch = ax.Children;
tc.verifyTrue(any(arrayfun(@(h) isa(h, 'matlab.graphics.chart.primitive.Surface'), ch)));
tc.verifyTrue(any(arrayfun(@(h) isa(h, 'matlab.graphics.primitive.Image'), ch)));
end
end
end
