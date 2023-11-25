
# For arbitrary intervals for primary event
observe_process2 <- function(linelist) {
  clinelist <- linelist |>
    data.table::copy() |>
    DT(, ptime_lwr := ptime_start) |>
    DT(, ptime_upr := ptime_end + 1) |>
    DT(, stime_lwr := stime_start) |>
    DT(, stime_upr := stime_end + 1) |>
    DT(, delay_lwr := max(stime_lwr - ptime_upr, 0)) |>
    DT(, delay_upr := stime_upr - ptime_lwr) |>
    # We assume observation time is the end of the maximum delay
    DT(, obs_at := stime_upr |>
         max() |>
         ceiling()
    )
  return(clinelist)
}

