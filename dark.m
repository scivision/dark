function dark(colors_in)
% Usage: dark(colors_in)
%
%  Dark-theme plots.
%
%  DARK converts a normal 'light-themed' plot to a dark theme.
%  To use, after creating a plot simply run "dark" to convert it.
%
%  colors_in.........optional character or character array of color specifiers
%                    A letter specifies a color; an array of letters tells
%                    DARK the order to apply colors to multi-data-series plots.
%                    If omitted, a default color table suitable for dark themes
%                    is used. DARK extends the set of standard single letter
%                    specifiers used by MATLAB and GNU Octave.
%
%                    The following specifiers are recognized:
%
%                    'y' - Yellow
%                    'c' - Cyan
%                    'm' - Magenta
%                    'g' - Green
%                    'r' - Red
%                    'p' - Peach (new)
%                    'o' - Orange (new)
%                    'j' - Jaybird (new)
%                    't' - Teal (new)
%                    'v' - Violet (new)
%                    'b' - Blue
%                    'w' - White
%
%  Notes:
%   1. Supported plot types
%      2-d line plots (plot command)
%      3-d line plots (plot3 command)
%      3-d surface plots (surf command)
%      stem plots (stem command)
%      bar plots (bar command)
%      horizontal bar plots (barh command)
%
%  Example: Make a simple dark themed line plot
%  >> plot(1:10); dark;
%
%  Example: Convert an annotated multi-data-series bar plot to a dark theme
%  Draw blue bars for the first series and peach bars for the second.
%  >> bar([(1:10)' (10:-1:1)']);
%  >> legend('this','that','Location','North');
%  >> xlabel('Blivit');
%  >> ylabel('Barvid');
%  >> title('This and That');
%  >> dark('bp');
%

    global colors %#ok<*GVMIS>

    if nargin == 0
        colors = fetch_colortab();
    else
        colors = fetch_colortab(lower(colors_in));
    end

    draw_canvas();
    graph_data();
    label_axes();
    handle_adornments();
    finish_up();

end % main function


function draw_canvas()

    % draw background
    set(gca,'Color','black')
    set(gcf,'Color','black')
    set(gca,'zcolor','white')
    if isoctave()
        set(gca,'xcolor','white')
        set(gca,'ycolor','white')
    end

end % function

function graph_data()

    if isoctave()
        go_graph_data()
    else
        ml_graph_data()
    end

end % function

function ml_graph_data()

    global colors

    % graph data
    h = get(gca,'Children');
    cc = 0;
    for kk = numel(h):-1:1
        cc = cc + 1;
        index = rem(cc-1,size(colors,1)) + 1;
        switch class(h(kk))
          case 'matlab.graphics.chart.primitive.Line'
            set(h(kk),'Color',colors(index,:))
            set(h(kk),'MarkerFaceColor',colors(index,:))
            set(h(kk),'MarkerEdgeColor',colors(index,:))
          case 'matlab.graphics.chart.primitive.Bar'
            set(h(kk),'FaceColor',colors(index,:))
            set(h(kk),'EdgeColor','white')
            set(h(kk),'EdgeAlpha',0.5)
          case 'matlab.graphics.chart.primitive.Stem'
            set(h(kk),'Color',colors(index,:))
            set(h(kk),'MarkerFaceColor',colors(index,:))
            set(h(kk),'MarkerEdgeColor',colors(index,:))
          case 'matlab.graphics.primitive.Patch'
            celight = get(h(kk),'EdgeColor');
            cflight = get(h(kk),'FaceColor');
            set(h(kk),'EdgeColor',[1 1 1] - celight)
            set(h(kk),'FaceColor',[1 1 1] - cflight)
          case 'matlab.graphics.primitive.Text'
            set(h(kk),'Color','w')
        end
    end

end % function

function go_graph_data()

    global colors

    % graph data
    h = get(gca,'Children');
    cc = 0;
    for kk = numel(h):-1:1
        cc = cc + 1;
        index = rem(cc-1,size(colors,1)) + 1;
        if isa(h, 'double')
            % octave
            switch lower(get(h(kk),'type'))
              case 'line'
                set(h(kk),'Color',colors(index,:))
              case 'hggroup'
                if isfield(get(h(kk)),'bargroup')
                    % bar plot
                    set(h(kk),'FaceColor',colors(index,:))
                    set(h(kk),'EdgeColor','white')
                else
                    % stem plot
                    set(h(kk),'Color',colors(index,:))
                    set(h(kk),'MarkerEdgeColor',colors(index,:))
                    if isnumeric(get(h(kk)).markerfacecolor)
                        set(h(kk),'MarkerFaceColor',colors(index,:))
                    end
                end
              case 'patch'
                celight = get(h(kk),'EdgeColor');
                cflight = get(h(kk),'FaceColor');
                set(h(kk),'EdgeColor',[1 1 1] - celight)
                set(h(kk),'FaceColor',[1 1 1] - cflight)
              case 'text'
                set(h(kk),'Color','w')
            end % hggroup
        end % double
    end % kk

end % function

function label_axes()

    if isoctave()
      go_label_axes();
    else
      ml_label_axes();
    end

end % function

function ml_label_axes()

    tt = get(gca,'title');
    xx = get(gca,'xaxis');
    yy = get(gca,'yaxis');
    set(tt,'Color','white')
    set(xx,'Color','white')
    set(yy,'Color','white')

end % function

function go_label_axes()

    % octave
    tt = get(gca,'title');
    xx = get(gca,'xlabel');
    yy = get(gca,'ylabel');
    zz = get(gca,'zlabel');
    set(tt,'Color','white')
    set(xx,'Color','white')
    set(yy,'Color','white')
    set(zz,'Color','white')

end % function

function handle_adornments()

    handle_legend();
    handle_colorbar();

end % function

function handle_legend()

    if isoctave()
      go_handle_legend();
    else
      ml_handle_legend();
    end

end % function

function ml_handle_legend()

    lgd = [];
    pc = get(gcf, 'Children');
    for kk = 1:numel(pc)
        if isa(pc(kk),'matlab.graphics.illustration.Legend')
            lgd = pc(kk);
            break
        end
    end
    if ~isempty(lgd)
        lgd.Color = 'black';
        lgd.TextColor = 'white';
        lgd.EdgeColor = 'white';
    end

end % function

function go_handle_legend()

    % octave
    h = get(gca,'Children');
    props = get(h(end));
    if isfield(props,'displayname') && ~isempty(props.displayname)
        lgd = legend;
        set(lgd,'Color','black')
        set(lgd,'EdgeColor','white')
        set(lgd,'TextColor','white')
    end

end % function

function handle_colorbar()

    if isoctave()
      go_handle_colorbar();
    else
      ml_handle_colorbar();
    end

end % function

function ml_handle_colorbar()

    cb = get(gca,'Colorbar');
    if ~isempty(cb)
        set(cb,'Color','white')
    end

end % function

function go_handle_colorbar()

    props = get(gca);
    if isfield(props,'__colorbar_handle__')
        cb = get(gca,'__colorbar_handle__');
        if ~isempty(cb)
            set(cb,'ycolor','white')
            set(cb,'fontsize',12)
        end
    end

end % function

function finish_up()

    if isoctave()
      go_finish_up();
    else
      ml_finish_up();
    end

end % function

function ml_finish_up()

    set(gca,'GridColor','white')
    set(gca,'GridAlpha',0.3)

end % function

function go_finish_up()

    props = get(gca);
    if isfield(props,'gridcolor')
        set(gca,'GridColor','white')
    end
    if isfield(props,'gridalpha')
        set(gca,'GridAlpha',0.3)
    end
    if isfield(props,'fontsize')
        set(gca,'FontSize',14)
    end

end % function

function colortab = fetch_colortab(colors_in)

    if nargin == 0
        fc = fieldnames(colortab_base());
        c = '';
        for kk = 1:numel(fc)
            c = [c fc{kk}]; %#ok<*AGROW>
        end
    else
        c = colors_in;
    end

    colortab =  [];
    colorbase = colortab_base();
    for kk = 1:numel(c)
        if isfield(colorbase,c(kk))
            colortab = [colortab; colorbase.(c(kk))];
        elseif c(kk) == 'k'
            colortab = [colortab; [0 0 0]]; % reluctantly support black
        else
            fprintf(2,'Ignoring unrecognized color specifier %s.\n', c(kk));
        end
    end

    if isempty(colortab)
        colortab = fetch_colortab();
    end

end % function

function colorbase = colortab_base()
    colorbase = struct();
    colorbase.y = [1 1 0]; % yellow
    colorbase.c = [0 1 1]; % cyan
    colorbase.m = [1 0 1]; % magenta
    colorbase.g = [0 1 0]; % green
    colorbase.r = [1 0 0]; % red
    colorbase.p = [0.9290 0.6940 0.1250]; % peach
    colorbase.o = [0.8500 0.3250 0.0980]; % orange
    colorbase.j = [0.3010 0.7450 0.9330]; % jaybird
    colorbase.t = [0.4660 0.6740 0.1880]; % teal
    colorbase.v = [0.4940 0.1840 0.5560]; % violet
    colorbase.b = [0 0 1]; % blue
    colorbase.w = [1 1 1]; % white
end % function

function y = isoctave()
    y = exist('OCTAVE_VERSION', 'builtin') ~= 0;
end % function
