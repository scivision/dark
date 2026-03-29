function hand(colors_in)
% Usage: hand(colors_in)
%
%  Hand-drawn-theme plots.
%
%  HAND renders simple plots into a hand-drawn look.
%  To use, after creating a plot run "hand" to convert it.
%
%  colors_in.........optional character or character array of color specifiers
%                    A letter specifies a color; an array of letters tells
%                    DARK the order to apply colors to multi-data-series plots.
%                    If omitted, a default color table suitable for hand-drawn
%                    themes is used. HAND includes a modified set of standard
%                    single letter specifiers used by MATLAB and GNU Octave.
%
%                    The following line color specifiers are recognized:
%
%                    'n' - Navy
%                    'r' - Red
%                    'g' - Green
%                    'e' - Grey
%                    'v' - Violet
%                    'k' - Black
%                    'p' - Peach
%                    'm' - Magenta
%                    'o' - Orange
%                    'j' - Jaybird
%                    't' - Teal
%                    'b' - Blue
%                    'w' - White
%
%  Notes:
%   1. Supported plot types
%      2-d line plots (plot command)
%
%  Example: Make a simple hand-drawn themed plot
%  >> plot(1:10); hand;
%
%  Example: Render a multi-data-series line plot in a hand-drawn theme
%  >> plot([real(exp(i*2*pi/1024*(0:1024)));imag(exp(i*2*pi/1024*(0:1024)))].');
%  >> xlabel('Time'); ylabel('Amplitude'); title('Wave'); grid on;
%  >> hand;
%

    global COLORS %#ok<*GVMIS>
    global CANVAS_RGB
    global FONT_NAME
    global FONT_SIZE
    global FONT_ANGLE

    if nargin == 0
        COLORS = fetch_colortab();
    else
        COLORS = fetch_colortab(lower(colors_in));
    end

    % Emulate engineering graph paper background
    CANVAS_RGB = [220 243 182]/256;

    [font_name, font_size, font_angle] = setup_font();
    FONT_NAME = font_name;
    FONT_SIZE = font_size;
    FONT_ANGLE = font_angle;

    draw_canvas();
    graph_data();
    label_axes()
    handle_adornments();
    finish_up();

end % main function

function [font_name, font_size, font_angle] = setup_font()
    font_angle = 'normal';
    font_size = 20;
    if ispc()
        %font_name = 'Comic Sans MS';
        font_name = 'Segoe Print';
    elseif isunix()
        font_name = 'xkcd Script';
        isfont = ~system("fc-list -q 'xkcd Script'");
        if ~isfont
            try
                isfont = install_font();
            catch err
                warning(err.identifier, '%s', err.message);
                isfont = false;
            end
            if isfont
                if ~isoctave()
                    estr = sprintf('\n\n');
                    estr = sprintf('%s    %s\n', estr,repmat('*',1,56));
                    estr = sprintf('%s    Restart MATLAB to refresh font list.\n', estr);
                    estr = sprintf('%s    %s\n\n', estr,repmat('*',1,56));
                    warning('%s', estr);
                else 
                    if strcmp(graphics_toolkit(),'gnuplot')
                        estr = sprintf('\n\n');
                        estr = sprintf('%s    %s\n', estr,repmat('*',1,56));
                        estr = sprintf('%s    GNU Octave is configured to use gnuplot graphics which\n', estr);
                        estr = sprintf('%s    is not compatible with HAND. Use the GNU Octave command\n', estr);
                        estr = sprintf('%s    available_graphics_toolkits() and change to a different\n', estr);
                        estr = sprintf('%s    toolkit with graphics_toolkit(new_toolkit_name).\n', estr);
                        estr = sprintf('%s    See help graphics_toolkit for more information.\n', estr);
                        estr = sprintf('%s    %s\n\n', estr,repmat('*',1,56));
                        warning('%s', estr);
                    end 
                end 
            else
                % font did not install, fallback to a standard font
                font_name = 'Times';  % <something standard>
                font_angle = 'italic';
            end % isfont
        end % ~isfont
    else
        warning('Only Windows and Linux are currently supported.');
        font_name = 'Pacifico';
    end % ispc()

end % function

function ok = install_font()
    % Linux only
    if ~isunix()
        ok = false;
        return
    end
    if ~exist('~/.local', 'dir')
        mkdir('~','.local')
    end
    if ~exist('~/.local/share', 'dir')
        mkdir('~/.local','share')
    end
    if ~exist('~/.local/share/fonts', 'dir')
        mkdir('~/.local/share','fonts')
    end
    if ~exist('~/.local/share/fonts/xkcd-script.ttf', 'file')
        P = mfilename('fullpath');
        fp = fileparts([P '.m']);
        ff = fullfile(fp,'xkcd-script.ttf'); 
        ok = copyfile(ff, '~/.local/share/fonts/');
        if ok
            system('fc-cache -f -y -v ~/.local/share/fonts/ 2> /dev/null');
            ok = ~system("fc-list -q 'xkcd Script'");
        end
    end
end % function

function draw_canvas()
    global CANVAS_RGB

    % emulate engineering graph paper background
    set(gca,'Color',CANVAS_RGB);
    set(gcf,'Color',CANVAS_RGB);
    set(gca,'zcolor','black');
    if isoctave()
        set(gca,'xcolor','black');
        set(gca,'ycolor','black');
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

    global COLORS

    % graph data
    h = get(gca,'Children');
    cc = 0;
    for kk = numel(h):-1:1
        cc = cc + 1;
        index = rem(cc-1,size(COLORS,1)) + 1;
        if isa(h(kk), 'matlab.graphics.chart.primitive.Line')
            set(h(kk),'Color',COLORS(index,:));
            set(h(kk),'MarkerFaceColor',COLORS(index,:));
            set(h(kk),'MarkerEdgeColor',COLORS(index,:));
            set(h(kk),'LineWidth',3);
        elseif isa(h(kk), 'matlab.graphics.chart.primitive.Bar')
            set(h(kk),'FaceColor',COLORS(index,:));
            set(h(kk),'EdgeColor','black');
            set(h(kk),'EdgeAlpha',0.5);
        elseif isa(h(kk), 'matlab.graphics.chart.primitive.Stem')
            set(h(kk),'Color',COLORS(index,:));
            set(h(kk),'MarkerFaceColor',COLORS(index,:));
            set(h(kk),'MarkerEdgeColor',COLORS(index,:));
        end
    end

end % function

function go_graph_data()

    global COLORS

    % graph data
    h = get(gca,'Children');
    cc = 0;
    for kk = numel(h):-1:1
        cc = cc + 1;
        index = rem(cc-1,size(COLORS,1)) + 1;
        if isa(h, 'double')
            % octave
            if strcmpi(get(h(kk),'type'),'line')
                set(h(kk),'Color',COLORS(index,:));
                set(h(kk),'LineWidth',3);
            elseif strcmpi(get(h(kk),'type'),'hggroup')
                if isfield(get(h(kk)),'bargroup')
                    % bar plot
                    set(h(kk),'FaceColor',COLORS(index,:));
                    set(h(kk),'EdgeColor','black');
                else
                    % stem plot
                    set(h(kk),'Color',COLORS(index,:));
                    set(h(kk),'MarkerEdgeColor',COLORS(index,:));
                    if isnumeric(get(h(kk)).markerfacecolor)
                        set(h(kk),'MarkerFaceColor',COLORS(index,:));
                    end
                end
            end % hggroup
        end % double
    end % kk

end % function

function label_axes()

    if isoctave()
      go_label_axes();
    else
      ml_label_axes()
    end

end % function

function ml_label_axes()
    global FONT_NAME
    global FONT_SIZE
    global FONT_ANGLE

    % Apply font
    tt = get(gca,'title');
    xx = get(gca,'xaxis');
    yy = get(gca,'yaxis');
    set(tt,'Color','black');
    set(xx,'Color','black');
    set(yy,'Color','black');
    if ~strcmpi(FONT_NAME,'default')
        set(gca,'FontName',FONT_NAME,'FontSize',FONT_SIZE,'FontAngle',FONT_ANGLE);
    else
        set(gca,'FontAngle',FONT_ANGLE);
    end

end % function

function go_label_axes()
    % octave
    global FONT_NAME
    global FONT_SIZE
    global FONT_ANGLE

    % Apply font
    tt = get(gca,'title');
    xx = get(gca,'xlabel');
    yy = get(gca,'ylabel');
    zz = get(gca,'zlabel');
    set(tt,'Color','black');
    set(xx,'Color','black');
    set(yy,'Color','black');
    set(zz,'Color','black');
    if ~strcmpi(FONT_NAME,'default')
        set(gca,'fontname',FONT_NAME,'fontSize',FONT_SIZE,'fontangle',FONT_ANGLE);
    else
        set(gca,'fontangle',FONT_ANGLE);
    end


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
    global CANVAS_RGB

    lgd = [];
    pc = get(gcf, 'Children');
    for kk = 1:numel(pc)
        if isa(pc(kk),'matlab.graphics.illustration.Legend')
            lgd = pc(kk);
            break
        end
    end
    if ~isempty(lgd)
        lgd.Color = CANVAS_RGB;
        lgd.TextColor = 'black';
        lgd.EdgeColor = 'black';
    end

end % function

function go_handle_legend()
    global CANVAS_RGB

    % octave
    h = get(gca,'Children');
    props = get(h(end));
    if isfield(props,'displayname') && ~isempty(props.displayname)
        lgd = legend;
        set(lgd,'Color',CANVAS_RGB);
        set(lgd,'EdgeColor','black');
        set(lgd,'TextColor','black');
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
        set(cb,'Color','black');
    end

end % function

function go_handle_colorbar()

    props = get(gca);
    if isfield(props,'__colorbar_handle__')
        cb = get(gca,'__colorbar_handle__');
        if ~isempty(cb)
            set(cb,'ycolor','black');
            set(cb,'fontsize',12);
        end
    end

end % function

function finish_up()

    if isoctave()
      go_finish_up();
    else
      ml_finish_up();
    end
    figure(gcf);

end % function

function ml_finish_up()

    cb = colortab_base();
    set(gca,'GridColor',cb.g);
    set(gca,'GridAlpha',0.5);

end % function

function go_finish_up()

    props = get(gca);
    if isfield(props,'gridcolor')
        cb = colortab_base();
        set(gca,'GridColor',cb.g);
    end
    if isfield(props,'gridalpha')
        set(gca,'GridAlpha',0.5);
    end
    if isfield(props,'fontsize')
        set(gca,'FontSize',20);
    end

end % function

function colortab = fetch_colortab(colors_in)

    if nargin == 0
        fc = fieldnames(colortab_base());
        c = '';
        for kk = 1:numel(fc)
            c = [c fc{kk}];
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
    colorbase.n = [0 0.4470 0.7410]/1.5;  % navy
    colorbase.r = [0.6350 0.0780 0.1840]; % red
    colorbase.g = [0.3023 0.6203 0.1812]; % green
    colorbase.e = [0.5    0.5    0.5   ]; % grey
    colorbase.v = [0.4940 0.1840 0.5560]; % violet
    colorbase.k = [0      0      0     ]; % black
    colorbase.p = [0.9290 0.6940 0.1250]; % peach
    colorbase.m = [1      0      1     ]; % magenta
    colorbase.o = [0.8500 0.3250 0.0980]; % orange
    colorbase.j = [0.3010 0.7450 0.9330]; % jaybird
    colorbase.t = [0.4660 0.6740 0.1880]; % teal
    colorbase.b = [0      0      1     ]; % blue
    colorbase.w = [1      1      1     ]; % white
end % function

function y = isoctave()
    y = exist('OCTAVE_VERSION', 'builtin') ~= 0;
end % function
