set terminal x11
set size 1,1
set grid
set nokey
set border 15
set tics scale 0
set xlabel "NZ_CP065640.1"
set ylabel "%SIM"
set format "%.0f"
set xrange [1:4995010]
set yrange [1:110]
set linestyle 1  lt 1 lw 3
set linestyle 2  lt 3 lw 3
set linestyle 3  lt 2 lw 3 pt 6 ps 1
plot \
 "comp1.2_plot_COV.fplot" title "FWD" w l ls 1, \
 "comp1.2_plot_COV.rplot" title "REV" w l ls 2

print "-- INTERACTIVE MODE --"
print "consult gnuplot docs for command list"
print "mouse 1: coords to clipboard"
print "mouse 2: mark on plot"
print "mouse 3: zoom box"
print "'h' for help in plot window"
print "enter to exit"
pause -1
