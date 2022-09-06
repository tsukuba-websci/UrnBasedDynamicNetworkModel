using DataFrames, CSV
using DataFramesMeta
using PlotlyJS
using DynamicNetworkMeasuringTools

include("./Utils.jl")

diffs = DataFrame(CSV.File("results/2022-08-22/diffs.csv"))

diffs_min = diffs[1, :]

rho = diffs_min.rho
nu = diffs_min.nu

function export_bestfit_min_r_label_with_history()
    min_rho_nu_diffs = @chain sort(diffs, :r) begin
        @rsubset(:rho .== rho, :nu .== nu)
    end

    min_r_diff = min_rho_nu_diffs[1, :]

    zeta = min_r_diff.zeta
    eta = min_r_diff.eta

    filename = params2str(rho, nu, zeta, eta)
    println(filename)
    history = DataFrame(CSV.File("results/2022-08-18/$(filename)--history.csv"))
    labels = DataFrame(CSV.File("results/2022-08-18/$(filename)--labels.csv"))

    _h = Tuple.(zip(history.src, history.dst))
    plt = plot_rich_get_richer_triangle(_h, length(_h) ÷ 100)
    savefig(plt, "temp_best_fit_r.png")

    leftjoined = rename(leftjoin(history, labels; on=:src => :id), :label => :label_src)
    history_with_labels = rename(
        leftjoin(leftjoined, labels; on=:dst => :id), :label => :label_dst
    )
    sorted_history_with_labels = sort(history_with_labels, :step)
    CSV.write("bestfit_min_r_label_with_history.csv", sorted_history_with_labels)
end

function export_bestfit_label_with_history()
    zeta = diffs_min.zeta
    eta = diffs_min.eta

    filename = params2str(rho, nu, zeta, eta)
    println(filename)
    history = DataFrame(CSV.File("results/2022-08-18/$(filename)--history.csv"))
    labels = DataFrame(CSV.File("results/2022-08-18/$(filename)--labels.csv"))

    _h = Tuple.(zip(history.src, history.dst))
    plt = plot_rich_get_richer_triangle(_h, length(_h) ÷ 100)
    savefig(plt, "temp_min_r.png")

    leftjoined = rename(leftjoin(history, labels; on=:src => :id), :label => :label_src)
    history_with_labels = rename(
        leftjoin(leftjoined, labels; on=:dst => :id), :label => :label_dst
    )
    sorted_history_with_labels = sort(history_with_labels, :step)
    CSV.write("bestfit_label_with_history.csv", sorted_history_with_labels)
end

export_bestfit_min_r_label_with_history()
export_bestfit_label_with_history()
