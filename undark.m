function undark()
% Usage: undark()
%
%  Convert dark-theme plots to light theme.
%
%  UNDARK converts a dark theme plot to the standard light theme.
%  To use, simply run "undark" on the current dark plot to convert it.
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
%  Example: Make a dark theme line plot then convert it back to light theme
%  >> plot(1:10); dark;
%  >> undark;
%
%  Example: Convert an annotated multi-data-series bar plot to a dark theme
%  Draw blue bars for the first series and peach bars for the second.
%  After the dark plot is rendered convert it back to light theme.
%  >> bar([(1:10)' (10:-1:1)']);
%  >> legend('this','that','Location','North');
%  >> xlabel('Blivit');
%  >> ylabel('Barvid');
%  >> title('This and That');
%  >> dark('bp');
%  >> undark('bp');
%

    global colors %#ok<*GVMIS>

    colors = fetch_colortab();

    draw_canvas();
    graph_data();
    label_axes();
    handle_adornments();
    finish_up();

end % main function


function draw_canvas()

    % draw background
    set(gca,'Color','white');
    set(gcf,'Color',0.94*[1 1 1]);
    set(gca,'zcolor','black');
    if isoctave()
        set(gcf,'Color','white');
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

    global colors

    % graph data
    h = get(gca,'Children');
    cc = 0;
    for kk = numel(h):-1:1
        cc = cc + 1;
        index = rem(cc-1,size(colors,1)) + 1;
        if isa(h(kk), 'matlab.graphics.chart.primitive.Line')
            set(h(kk),'Color',colors(index,:));
            if ~strcmp(get(h(kk),'MarkerFaceColor'), 'none')
                set(h(kk),'MarkerFaceColor',colors(index,:));
            end
            if ~strcmp(get(h(kk),'MarkerEdgeColor'), 'auto')
                set(h(kk),'MarkerEdgeColor',colors(index,:));
            end
        elseif isa(h(kk), 'matlab.graphics.chart.primitive.Bar')
            set(h(kk),'FaceColor',colors(index,:));
            set(h(kk),'EdgeColor','black');
            set(h(kk),'EdgeAlpha',1.0);
        elseif isa(h(kk), 'matlab.graphics.chart.primitive.Stem')
            set(h(kk),'Color',colors(index,:));
            set(h(kk),'MarkerFaceColor',colors(index,:));
            set(h(kk),'MarkerEdgeColor',colors(index,:));
        elseif isa(h(kk), 'matlab.graphics.primitive.Patch')
            celight = get(h(kk),'EdgeColor');
            cflight = get(h(kk),'FaceColor');
            set(h(kk),'EdgeColor',[1 1 1] - celight);
            set(h(kk),'FaceColor',[1 1 1] - cflight);
        elseif isa(h(kk), 'matlab.graphics.primitive.Text')
            set(h(kk),'Color','w');
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
            if strcmpi(get(h(kk),'type'),'line')
                set(h(kk),'Color',colors(index,:));
            elseif strcmpi(get(h(kk),'type'),'hggroup')
                if isfield(get(h(kk)),'bargroup')
                    % bar plot
                    %set(h(kk),'FaceColor','flat');
                    set(h(kk),'FaceColor',colors(index,:));
                    set(h(kk),'EdgeColor','black');
                else
                    % stem plot
                    set(h(kk),'Color',colors(index,:));
                    set(h(kk),'MarkerEdgeColor',colors(index,:));
                    if isnumeric(get(h(kk)).markerfacecolor)
                        set(h(kk),'MarkerFaceColor',colors(index,:));
                    end
                end
            elseif strcmpi(get(h(kk),'type'),'patch')
                celight = get(h(kk),'EdgeColor');
                cflight = get(h(kk),'FaceColor');
                set(h(kk),'EdgeColor',[1 1 1] - celight);
                set(h(kk),'FaceColor',[1 1 1] - cflight);
            elseif strcmpi(get(h(kk),'type'),'text')
                set(h(kk),'Color','k');
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
    set(tt,'Color','black');
    set(xx,'Color','black');
    set(yy,'Color','black');

end % function

function go_label_axes()

    % octave
    tt = get(gca,'title');
    xx = get(gca,'xlabel');
    yy = get(gca,'ylabel');
    set(tt,'Color','black');
    set(xx,'Color','black');
    set(yy,'Color','black');

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
        lgd.Color = 'white';
        lgd.TextColor = 'black';
        lgd.EdgeColor = 'black';
    end

end % function

function go_handle_legend()

    % octave
    h = get(gca,'Children');
    props = get(h(end));
    if isfield(props,'displayname') && ~isempty(props.displayname)
        lgd = legend;
        set(lgd,'Color','white');
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
        set(cb,'Color',0.15*[1 1 1]);
    end

end % function

function go_handle_colorbar()

    props = get(gca);
    if isfield(props,'__colorbar_handle__')
        cb = get(gca,'__colorbar_handle__');
        if ~isempty(cb)
            set(cb,'ycolor','white');
            set(cb,'ycolor',0.15*[1 1 1]);
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

end % function

function ml_finish_up()

    set(gca,'GridColor',0.15*[1 1 1]);
    set(gca,'GridAlpha',0.2);

end % function

function go_finish_up()

    props = get(gca);
    if isfield(props,'gridcolor')
        set(gca,'GridColor',0.15*[1 1 1]);
    end
    if isfield(props,'gridalpha')
        set(gca,'GridAlpha',0.2);
    end
    if isfield(props,'fontsize')
        set(gca,'FontSize',14);
    end

end % function

function colortab = fetch_colortab()

    colortab = [ [0.0000, 0.4470, 0.7410]
                 [0.8500, 0.3250, 0.0980]
                 [0.9290, 0.6940, 0.1250]
                 [0.4940, 0.1840, 0.5560]
                 [0.4660, 0.6740, 0.1880]
                 [0.3010, 0.7450, 0.9330]
                 [0.6350, 0.0780, 0.1840]
                 [0.0000, 0.4470, 0.7410]
                 [0.8500, 0.3250, 0.0980]
                 [0.9290, 0.6940, 0.1250]
                 [0.4940, 0.1840, 0.5560]
                 [0.4660, 0.6740, 0.1880]
                 [0.3010, 0.7450, 0.9330]
                 [0.6350, 0.0780, 0.1840]
                 [0.0000, 0.4470, 0.7410]
                 [0.8500, 0.3250, 0.0980]
                 [0.9290, 0.6940, 0.1250]
                 [0.4940, 0.1840, 0.5560]
                 [0.4660, 0.6740, 0.1880]
                 [0.3010, 0.7450, 0.9330]
                 [0.6350, 0.0780, 0.1840] ];

end % function

function y = isoctave()
    y = exist('OCTAVE_VERSION', 'builtin') ~= 0;
end % function
