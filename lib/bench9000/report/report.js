// Copyright (c) 2014, 2015 Oracle and/or its affiliates. All rights reserved. This
// code is released under a tri EPL/GPL/LGPL license. You can use it,
// redistribute it and/or modify it under the terms of the:
//
// Eclipse Public License version 1.0
// GNU General Public License version 2
// GNU Lesser General Public License version 2.1

$(function () {
    // Colours from http://emilis.info/other/extended_tango/

    var implementation_colours = {
        // MRI in red
        "1.8.7-p375": "#270000",
        "1.9.3-p551": "#600000",
        "2.0.0-p648": "#a40000",
        "2.1.8": "#cc0000",
        "2.2.4": "#ef2929",
        "2.3.0": "#f05858",

        // JRuby in blue
        "jruby-9.0.5.0-int": "#00202a",
        "jruby-9.0.5.0-noindy": "#0a3050",
        "jruby-9.0.5.0-indy": "#204a87",
        "jruby-9.0.5.0-int-graal": "#3465a4",
        "jruby-9.0.5.0-noindy-graal": "#729fcf",
        "jruby-9.0.5.0-indy-graal": "#97c4f0",

        // Rubinius in grey
        "rbx-3.14-int": "#555753",
        "rbx-3.14": "#babdb6",

        // Topaz in green
        "topaz-dev": "#73d216",

        // Truffle in purple
        "jruby-dev-truffle-nograal": "#5c3566",
        "jruby-dev-truffle-graal": "#ad7fa8"
    };
    
    var other_colours = [
      "#888a85", "#c4a000", "#ce5c00", "#8f5902", "#4e9a06", "#204a87",
      "#5c3566", "#a40000", "#d3d7cf", "#fce94f", "#fcaf3e", "#e9b96e",
      "#8ae234", "#729fcf", "#ad7fa8", "#ef2929"
    ];

    var best_implementations = [
        "2.3.0",
        "jruby-9.0.5.0-indy",
        "jruby-dev-indy",
        "rbx-3.14",
        "topaz-dev",
        "jruby-dev-truffle-graal"
    ];

    var production_benchmarks = [
        "chunky-canvas-resampling-steps-residues",
        "chunky-canvas-resampling-steps",
        "chunky-canvas-resampling-nearest-neighbor",
        "chunky-canvas-resampling-bilinear",
        "chunky-decode-png-image-pass",
        "chunky-encode-png-image-pass-to-stream",
        "chunky-color-compose-quick",
        "chunky-color-r",
        "chunky-color-g",
        "chunky-color-b",
        "chunky-color-a",
        "chunky-operations-compose",
        "chunky-operations-replace",
        "psd-imagemode-rgb-combine-rgb-channel",
        "psd-imagemode-cmyk-combine-cmyk-channel",
        "psd-imagemode-greyscale-combine-greyscale-channel",
        "psd-imageformat-rle-decode-rle-channel",
        "psd-imageformat-layerraw-parse-raw",
        "psd-color-cmyk-to-rgb",
        "psd-compose-normal",
        "psd-compose-darken",
        "psd-compose-multiply",
        "psd-compose-color-burn",
        "psd-compose-linear-burn",
        "psd-compose-lighten",
        "psd-compose-screen",
        "psd-compose-color-dodge",
        "psd-compose-linear-dodge",
        "psd-compose-overlay",
        "psd-compose-soft-light",
        "psd-compose-hard-light",
        "psd-compose-vivid-light",
        "psd-compose-linear-light",
        "psd-compose-pin-light",
        "psd-compose-hard-mix",
        "psd-compose-difference",
        "psd-compose-exclusion",
        "psd-renderer-clippingmask-apply",
        "psd-renderer-mask-apply",
        "psd-renderer-blender-compose",
        "psd-util-clamp",
        "psd-util-pad2",
        "psd-util-pad4"
    ];

    Chart.defaults.global.multiTooltipTemplate = "<%=datasetLabel%>: <%= value %>";
    Chart.defaults.global.animation = false;

    function product(samples) {
        return samples.reduce(function (a, b) {
            return a * b;
        }, 1);
    }

    function geo_mean(samples) {
        return Math.pow(product(samples), 1 / samples.length);
    }

    function lookup(measurements, benchmark, implementation) {
        var filtered = measurements.filter(function (m) {
            return m.benchmark == benchmark && m.implementation == implementation;
        });

        if (filtered.length == 0 || filtered[0] == undefined) {
            console.log("no hit for " + benchmark + " " + implementation);
        }

        return filtered[0];
    }

    var speedup_reference_implementation = bench_data.implementations[0];
    var speedup_summarised = true;
    var speedup_visible_implementations = bench_data.implementations;
    var speedup_visible_benchmarks = bench_data.benchmarks;

    var speedup_chart;
    var baseline_enabled = true;

    var rebuild_speedup_disabled = false;

    function rebuild_speedup() {
        if (rebuild_speedup_disabled) {
            return;
        }

        var speedup_data;
        var get_value = function (b, i) {
            var score = lookup(bench_data.measurements, b, i).score;
            if (baseline_enabled) {
                return score / lookup(bench_data.measurements, b, speedup_reference_implementation).score;
            } else {
                return score;
            }
        };

        var get_error_value = function (b, i) {
            if (baseline_enabled) {
                var score = lookup(bench_data.measurements, b, i).score;
                var relative_score = score /
                    lookup(bench_data.measurements, b, speedup_reference_implementation).score;
                var ratio = score / relative_score;
                return lookup(bench_data.measurements, b, i).score_error / ratio;
            } else {
                return lookup(bench_data.measurements, b, i).score_error;
            }
        };
        
        var get_colour = function (i) {
          var colour = implementation_colours[i];
          
          if (colour === undefined) {
            return other_colours[Math.floor(Math.random() * other_colours.length)];
          }
          
          return colour;
        };
        
        if (speedup_summarised) {
            speedup_data = {
                labels: speedup_visible_implementations,
                datasets: [
                    {
                        fillColors: speedup_visible_implementations.map(get_colour),
                        strokeColors: speedup_visible_implementations.map(get_colour),
                        data: speedup_visible_implementations.map(function (i) {
                            return geo_mean(speedup_visible_benchmarks
                                .filter(function (b) {
                                    return !(lookup(bench_data.measurements, b, speedup_reference_implementation).failed ||
                                    lookup(bench_data.measurements, b, i).failed);
                                }).map(function (b) {
                                        return get_value(b, i);
                                    }
                                ));
                        }),
                        error: speedup_visible_implementations.map(function (i) {
                            return geo_mean(speedup_visible_benchmarks
                                .filter(function (b) {
                                    return !(lookup(bench_data.measurements, b, speedup_reference_implementation).failed
                                    || lookup(bench_data.measurements, b, i).failed);
                                }).map(function (b) {
                                        return get_error_value(b, i);
                                    }
                                ));
                        })
                    }
                ]
            };
        } else {
            speedup_data = {
                labels: speedup_visible_benchmarks,
                datasets: speedup_visible_implementations.map(function (i) {
                    return {
                        label: i,
                        fillColor: get_colour(i),
                        strokeColor: get_colour(i),
                        data: speedup_visible_benchmarks.map(function (b) {
                            if (lookup(bench_data.measurements, b, speedup_reference_implementation).failed
                                || lookup(bench_data.measurements, b, i).failed) {
                                return 0;
                            } else {
                                return get_value(b, i);
                            }
                        }),
                        error: speedup_visible_benchmarks.map(function (b) {
                            if (lookup(bench_data.measurements, b, speedup_reference_implementation).failed
                                || lookup(bench_data.measurements, b, i).failed) {
                                return 0;
                            } else {
                                return get_error_value(b, i);
                            }
                        })
                    };
                })
            };
        }

        if (speedup_chart != undefined) {
            speedup_chart.destroy();
            $("#speedup_chart")[0].width = 600;
            $("#speedup_chart")[0].height = 400;
        }

        speedup_chart = new Chart($("#speedup_chart")[0].getContext("2d")).Bar(speedup_data);
    }

    rebuild_speedup();

    $("#summary-summarised").change(function () {
        speedup_summarised = $('#summary-summarised').is(':checked');
        rebuild_speedup();
    });

    $("#baseline-enabled").change(function () {
        baseline_enabled = $('#baseline-enabled').is(':checked');
        $("#speedup-baseline").prop("disabled", !baseline_enabled);
        $("#speedup_chart")
            .find("~ .yaxis")
            .html(baseline_enabled ? "Speedup relative to<br>baseline implementation (s/s)" : "Score, higher is better");

        rebuild_speedup();
    });

    $("#speedup-baseline").change(function (option) {
        speedup_reference_implementation = $(this).find('option:selected').val();
        rebuild_speedup();
    });

    var speedup_impl_checkboxes = {};

    bench_data.implementations.forEach(function (i) {
        $("#speedup-baseline").append($("<option></option>").text(i));

        var checkbox = $("<input type='checkbox' checked>");
        speedup_impl_checkboxes[i] = checkbox;

        checkbox.change(function () {
            if (checkbox.is(':checked')) {
                speedup_visible_implementations = bench_data.implementations.filter(function (ip) {
                    return speedup_visible_implementations.indexOf(ip) != -1 || ip == i;
                });
            } else {
                speedup_visible_implementations = bench_data.implementations.filter(function (ip) {
                    return speedup_visible_implementations.indexOf(ip) != -1 && ip != i;
                });
            }

            rebuild_speedup();
        });

        $("#speedup-implementations")
            .append($("<div class='col-sm-offset-2 col-sm-8'>")
                .append($("<div class='checkbox'>")
                    .append($("<label></label>")
                        .append(checkbox)
                        .append(" ")
                        .append(i))));
    });

    $("#speedup-impl-all").click(function () {
        rebuild_speedup_disabled = true;
        bench_data.implementations.forEach(function (i) {
            var box = speedup_impl_checkboxes[i];
            box.prop('checked', true);
            box.change();
        });
        rebuild_speedup_disabled = false;
        rebuild_speedup();
    });

    $("#speedup-impl-none").click(function () {
        rebuild_speedup_disabled = true;
        bench_data.implementations.forEach(function (i) {
            var box = speedup_impl_checkboxes[i];
            box.prop('checked', false);
            box.change();
        });
        rebuild_speedup_disabled = false;
        rebuild_speedup();
    });

    $("#speedup-impl-best").click(function () {
        rebuild_speedup_disabled = true;
        bench_data.implementations.forEach(function (i) {
            var box = speedup_impl_checkboxes[i];
            box.prop('checked', best_implementations.indexOf(i) != -1);
            box.change();
        });
        rebuild_speedup_disabled = false;
        rebuild_speedup();
    });

    $("#speedup-baseline").val(speedup_reference_implementation);

    var speedup_bench_checkboxes = {};

    bench_data.benchmarks.forEach(function (b) {
        var checkbox = $("<input type='checkbox' checked>");
        speedup_bench_checkboxes[b] = checkbox;

        checkbox.change(function () {
            if (checkbox.is(':checked')) {
                speedup_visible_benchmarks = bench_data.benchmarks.filter(function (bp) {
                    return speedup_visible_benchmarks.indexOf(bp) != -1 || bp == b;
                });
            } else {
                speedup_visible_benchmarks = bench_data.benchmarks.filter(function (bp) {
                    return speedup_visible_benchmarks.indexOf(bp) != -1 && bp != b;
                });
            }

            rebuild_speedup();
        });

        $("#speedup-benchmarks")
            .append($("<div class='col-sm-offset-2 col-sm-8'>")
                .append($("<div class='checkbox'>")
                    .append($("<label></label>")
                        .append(checkbox)
                        .append(" ")
                        .append(b))));
    });

    $("#speedup-bench-all").click(function () {
        rebuild_speedup_disabled = true;
        bench_data.benchmarks.forEach(function (i) {
            var box = speedup_bench_checkboxes[i];
            box.prop('checked', true);
            box.change();
        });
        rebuild_speedup_disabled = false;
        rebuild_speedup();
    });

    $("#speedup-bench-none").click(function () {
        rebuild_speedup_disabled = true;
        bench_data.benchmarks.forEach(function (i) {
            var box = speedup_bench_checkboxes[i];
            box.prop('checked', false);
            box.change();
        });
        rebuild_speedup_disabled = false;
        rebuild_speedup();
    });

    if (!bench_data.benchmarks.some(function (b) {
            return production_benchmarks.indexOf(b) == -1;
        })) {
        $("#speedup-bench-synth").hide();
    }

    $("#speedup-bench-synth").click(function () {
        rebuild_speedup_disabled = true;
        bench_data.benchmarks.forEach(function (b) {
            var box = speedup_bench_checkboxes[b];
            box.prop('checked', production_benchmarks.indexOf(b) == -1);
            box.change();
        });
        rebuild_speedup_disabled = false;
        rebuild_speedup();
    });

    if (!bench_data.benchmarks.some(function (b) {
            return production_benchmarks.indexOf(b) != -1;
        })) {
        $("#speedup-bench-prod").hide();
    }

    $("#speedup-bench-prod").click(function () {
        rebuild_speedup_disabled = true;
        bench_data.benchmarks.forEach(function (b) {
            var box = speedup_bench_checkboxes[b];
            box.prop('checked', production_benchmarks.indexOf(b) != -1);
            box.change();
        });
        rebuild_speedup_disabled = false;
        rebuild_speedup();
    });

    var warmup_benchmark = bench_data.benchmarks[0];
    var warmup_visible_implementations = bench_data.implementations;

    var warmup_chart;

    var rebuild_warmup_disabled = false;

    function rebuild_warmup() {
        if (rebuild_warmup_disabled) {
            return;
        }

        var max_iterations = warmup_visible_implementations.map(function (i) {
            var measurement = lookup(bench_data.measurements, warmup_benchmark, i);
            if (measurement.failed) {
                return 0;
            } else {
                return measurement.warmup_samples.length + measurement.samples.length;
            }
        }).reduce(function (a, b) {
            return Math.max(a, b);
        });

        var labels = [];

        for (var n = 0; n < max_iterations; n++) {
            labels[n] = n;
        }

        var warmup_data = {
            labels: labels,
            datasets: warmup_visible_implementations.map(function (i) {
                var measurement = lookup(bench_data.measurements, warmup_benchmark, i);

                var data;

                if (measurement.failed) {
                    data = [];
                } else {
                    data = measurement.warmup_samples.concat(measurement.samples);
                }

                return {
                    label: i,
                    strokeColor: implementation_colours[i],
                    fillColor: "transparent",
                    pointColor: implementation_colours[i],
                    data: data
                };
            })
        };

        if (warmup_chart != undefined) {
            warmup_chart.destroy();
            $("#warmup_chart")[0].width = 600;
            $("#warmup_chart")[0].height = 400;
        }

        warmup_chart = new Chart($("#warmup_chart")[0].getContext("2d")).Line(warmup_data, {
            scaleBeginAtZero: true
        });
    }

    rebuild_warmup();

    $("#warmup-benchmark").change(function (option) {
        warmup_benchmark = $(this).find('option:selected').val();
        rebuild_warmup();
    });

    bench_data.benchmarks.forEach(function (b) {
        $("#warmup-benchmark").append($("<option></option>").text(b));
    });

    var warmup_impl_checkboxes = {};

    bench_data.implementations.forEach(function (i) {
        var checkbox = $("<input type='checkbox' checked>");
        warmup_impl_checkboxes[i] = checkbox;

        checkbox.change(function () {
            if (checkbox.is(':checked')) {
                warmup_visible_implementations = bench_data.implementations.filter(function (ip) {
                    return warmup_visible_implementations.indexOf(ip) != -1 || ip == i;
                });
            } else {
                warmup_visible_implementations = bench_data.implementations.filter(function (ip) {
                    return warmup_visible_implementations.indexOf(ip) != -1 && ip != i;
                });
            }

            rebuild_warmup();
        });

        $("#warmup-implementations")
            .append($("<div class='col-sm-offset-2 col-sm-8'>")
                .append($("<div class='checkbox'>")
                    .append($("<label></label>")
                        .append(checkbox)
                        .append(" ")
                        .append(i))));
    });

    $("#warmup-impl-all").click(function () {
        rebuild_warmup_disabled = true;
        bench_data.implementations.forEach(function (i) {
            var box = warmup_impl_checkboxes[i];
            box.prop('checked', true);
            box.change();
        });
        rebuild_warmup_disabled = false;
        rebuild_warmup();
    });

    $("#warmup-impl-none").click(function () {
        rebuild_warmup_disabled = true;
        bench_data.implementations.forEach(function (i) {
            var box = warmup_impl_checkboxes[i];
            box.prop('checked', false);
            box.change();
        });
        rebuild_warmup_disabled = false;
        rebuild_warmup();
    });

    $("#warmup-impl-best").click(function () {
        rebuild_warmup_disabled = true;
        bench_data.implementations.forEach(function (i) {
            var box = warmup_impl_checkboxes[i];
            box.prop('checked', best_implementations.indexOf(i) != -1);
            box.change();
        });
        rebuild_warmup_disabled = false;
        rebuild_warmup();
    });

    bench_data.benchmarks.forEach(function (b) {
        bench_data.implementations.forEach(function (i) {
            if (lookup(bench_data.measurements, b, i).failed) {
                $("#failures-list").append($("<li>").text(i + " " + b));
            }
        });
        rebuild_warmup();
    });

    if ($("#failures-list").children().length == 0) {
        $("#failures-list").append($("<li>").text("No failures"));
    }

    $(window).resize(function () {
        var canvas_offset = $($("canvas")[0]).offset();
        $(".yaxis").css('left', canvas_offset.left - 50);
    });

    $(window).resize();

});
