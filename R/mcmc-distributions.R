#' Histograms and kernel density plots of MCMC draws
#'
#' Various types of histograms and kernel density plots of MCMC draws. See the
#' \strong{Plot Descriptions} section, below, for details.
#'
#' @name MCMC-distributions
#' @family MCMC
#'
#' @template args-mcmc-x
#' @template args-pars
#' @template args-regex_pars
#' @template args-transformations
#' @template args-facet_args
#' @param ... Currently ignored.
#'
#' @template return-ggplot
#'
#' @section Plot Descriptions:
#' \describe{
#'   \item{\code{mcmc_hist}}{
#'    Histograms of posterior draws with all chains merged.
#'   }
#'   \item{\code{mcmc_dens}}{
#'    Kernel density plots of posterior draws with all chains merged.
#'   }
#'   \item{\code{mcmc_hist_by_chain}}{
#'    Histograms of posterior draws with chains separated via faceting.
#'   }
#'   \item{\code{mcmc_dens_overlay}}{
#'    Kernel density plots of posterior draws with chains separated but
#'    overlaid on a single plot.
#'   }
#'   \item{\code{mcmc_violin}}{
#'    The density estimate of each chain is plotted as a violin with
#'    horizontal lines at notable quantiles.
#'   }
#'   \item{\code{mcmc_dens_chains}}{
#'    Ridgeline kernel density plots of posterior draws with chains separated
#'    but overlaid on a single plot. In \code{mcmc_dens_overlay} parameters
#'    appear in separate facets; in \code{mcmc_dens_chains} they appear in the
#'    same panel and can overlap vertically.
#'   }
#' }
#'
#' @examples
#' set.seed(9262017)
#' # some parameter draws to use for demonstration
#' x <- example_mcmc_draws()
#' dim(x)
#' dimnames(x)
#'
#' ##################
#' ### Histograms ###
#' ##################
#'
#' # histograms of all parameters
#' color_scheme_set("brightblue")
#' mcmc_hist(x)
#'
#' # histograms of some parameters
#' color_scheme_set("pink")
#' mcmc_hist(x, pars = c("alpha", "beta[2]"))
#' \donttest{
#' mcmc_hist(x, pars = "sigma", regex_pars = "beta")
#' }
#' # example of using 'transformations' argument to plot log(sigma),
#' # and parsing facet labels (e.g. to get greek letters for parameters)
#' mcmc_hist(x, transformations = list(sigma = "log"),
#'           facet_args = list(labeller = ggplot2::label_parsed)) +
#'           facet_text(size = 15)
#' \donttest{
#' # instead of list(sigma = "log"), you could specify the transformation as
#' # list(sigma = log) or list(sigma = function(x) log(x)), but then the
#' # label for the transformed sigma is 't(sigma)' instead of 'log(sigma)'
#' mcmc_hist(x, transformations = list(sigma = log))
#'
#' # separate histograms by chain
#' color_scheme_set("pink")
#' mcmc_hist_by_chain(x, regex_pars = "beta")
#' }
#'
#' #################
#' ### Densities ###
#' #################
#'
#' mcmc_dens(x, pars = c("sigma", "beta[2]"),
#'           facet_args = list(nrow = 2))
#' \donttest{
#' # separate and overlay chains
#' color_scheme_set("mix-teal-pink")
#' mcmc_dens_overlay(x, pars = c("sigma", "beta[2]"),
#'                   facet_args = list(nrow = 2)) +
#'                   facet_text(size = 14)
#' x2 <- example_mcmc_draws(params = 6)
#' mcmc_dens_chains(x2, pars = c("beta[1]", "beta[2]", "beta[3]"))
#' }
#' # separate chains as violin plots
#' color_scheme_set("green")
#' mcmc_violin(x) + panel_bg(color = "gray20", size = 2, fill = "gray30")
#'
NULL

#' @rdname MCMC-distributions
#' @export
#' @template args-hist
#' @template args-hist-freq
#'
mcmc_hist <- function(x,
                      pars = character(),
                      regex_pars = character(),
                      transformations = list(),
                      facet_args = list(),
                      ...,
                      binwidth = NULL,
                      breaks = NULL,
                      freq = TRUE) {
  check_ignored_arguments(...)
  .mcmc_hist(
    x,
    pars = pars,
    regex_pars = regex_pars,
    transformations = transformations,
    facet_args = facet_args,
    binwidth = binwidth,
    breaks = breaks,
    by_chain = FALSE,
    freq = freq,
    ...
  )
}

#' @rdname MCMC-distributions
#' @export
mcmc_dens <- function(x,
                      pars = character(),
                      regex_pars = character(),
                      transformations = list(),
                      facet_args = list(),
                      ...,
                      trim = FALSE) {
  check_ignored_arguments(...)
  .mcmc_dens(
    x,
    pars = pars,
    regex_pars = regex_pars,
    transformations = transformations,
    facet_args = facet_args,
    by_chain = FALSE,
    trim = trim,
    ...
  )
}

#' @rdname MCMC-distributions
#' @export
#'
mcmc_hist_by_chain <- function(x,
                               pars = character(),
                               regex_pars = character(),
                               transformations = list(),
                               facet_args = list(),
                               ...,
                               binwidth = NULL,
                               freq = TRUE) {
  check_ignored_arguments(...)
  .mcmc_hist(
    x,
    pars = pars,
    regex_pars = regex_pars,
    transformations = transformations,
    facet_args = facet_args,
    binwidth = binwidth,
    by_chain = TRUE,
    freq = freq,
    ...
  )
}

#' @rdname MCMC-distributions
#' @export
mcmc_dens_overlay <- function(x,
                              pars = character(),
                              regex_pars = character(),
                              transformations = list(),
                              facet_args = list(),
                              color_chains = TRUE,
                              ...,
                              trim = FALSE) {
  check_ignored_arguments(...)
  .mcmc_dens(
    x,
    pars = pars,
    regex_pars = regex_pars,
    transformations = transformations,
    facet_args = facet_args,
    by_chain = TRUE,
    color_chains = color_chains,
    trim = trim,
    ...
  )
}

#' @rdname MCMC-distributions
#' @template args-density-controls
#' @param color_chains option for whether to separately color chains.
#' @export
mcmc_dens_chains <- function(x, pars = character(), regex_pars = character(),
                             transformations = list(),
                             color_chains = TRUE,
                             ...,
                             bw = NULL, adjust = NULL, kernel = NULL,
                             n_dens = NULL) {
  check_ignored_arguments(...)
  data <- mcmc_dens_chains_data(x, pars = pars, regex_pars = regex_pars,
                                transformations = transformations, bw = bw,
                                adjust = adjust, kernel = kernel,
                                n_dens = n_dens)

  n_chains <- length(unique(data$chain))
  if (n_chains == 1) STOP_need_multiple_chains()

  # An empty data-frame to train legend colors
  line_training <- dplyr::slice(data, 0)

  if (color_chains) {
    scale_color <- scale_color_manual(values = chain_colors(n_chains))
  } else {
    scale_color <- scale_color_manual(
      values = rep(get_color("m"), n_chains),
      guide = "none")
  }

  ggplot(data) +
    aes_(x = ~ x, y = ~ parameter, color = ~ chain,
         group = ~ interaction(chain, parameter)) +
    geom_line(data = line_training) +
    ggridges::geom_density_ridges(
      aes_(height = ~ density),
      stat = "identity",
      fill = NA,
      show.legend = FALSE) +
    labs(color = "Chain") +
    scale_y_discrete(limits = unique(rev(data$parameter)),
                     expand = c(0.05, .6)) +
    scale_color +
    bayesplot_theme_get() +
    yaxis_title(FALSE) +
    xaxis_title(FALSE) +
    grid_lines_y(color = "gray90") +
    theme(axis.text.y = element_text(hjust = 1, vjust = 0))
}

#' @rdname MCMC-distributions
#' @export
mcmc_dens_chains_data <- function(x, pars = character(),
                                  regex_pars = character(),
                                  transformations = list(),
                                  ...,
                                  bw = NULL, adjust = NULL, kernel = NULL,
                                  n_dens = NULL) {
  check_ignored_arguments(...)

  x %>%
    prepare_mcmc_array(pars = pars, regex_pars = regex_pars,
                       transformations = transformations) %>%
    melt_mcmc() %>%
    compute_column_density(c(.data$Parameter, .data$Chain), .data$Value,
                           interval_width = 1,
                           bw = bw, adjust = adjust, kernel = kernel,
                           n_dens = n_dens) %>%
    mutate(Chain = factor(.data$Chain)) %>%
    rlang::set_names(tolower) %>%
    dplyr::as_tibble()
}

#' @rdname MCMC-distributions
#' @inheritParams ppc_violin_grouped
#' @export
mcmc_violin <- function(x,
                        pars = character(),
                        regex_pars = character(),
                        transformations = list(),
                        facet_args = list(),
                        ...,
                        probs = c(0.1, 0.5, 0.9)) {
  check_ignored_arguments(...)
  .mcmc_dens(
    x,
    pars = pars,
    regex_pars = regex_pars,
    transformations = transformations,
    facet_args = facet_args,
    geom = "violin",
    probs = probs,
    ...
  )
}







# internal -----------------------------------------------------------------
.mcmc_hist <- function(x,
                      pars = character(),
                      regex_pars = character(),
                      transformations = list(),
                      facet_args = list(),
                      binwidth = NULL,
                      breaks = NULL,
                      by_chain = FALSE,
                      freq = TRUE,
                      ...) {
  x <- prepare_mcmc_array(x, pars, regex_pars, transformations)
  if (by_chain && !has_multiple_chains(x))
    STOP_need_multiple_chains()

  data <- melt_mcmc(x, value.name = "value")
  n_param <- num_params(data)

  graph <- ggplot(data, set_hist_aes(freq)) +
    geom_histogram(
      fill = get_color("mid"),
      color = get_color("mid_highlight"),
      size = .25,
      na.rm = TRUE,
      binwidth = binwidth,
      breaks = breaks
    )

  if (is.null(facet_args[["scales"]]))
    facet_args[["scales"]] <- "free"
  if (!by_chain) {
    if (n_param > 1) {
      facet_args[["facets"]] <- ~ Parameter
      graph <- graph + do.call("facet_wrap", facet_args)
    }
  } else {
    facet_args[["facets"]] <- if (n_param > 1)
      "Chain ~ Parameter" else "Chain ~ ."
    graph <- graph +
      do.call("facet_grid", facet_args) +
      force_axes_in_facets()
  }

  if (n_param == 1)
    graph <- graph + xlab(levels(data$Parameter))

  graph +
    dont_expand_y_axis(c(0.005, 0)) +
    bayesplot_theme_get() +
    yaxis_text(FALSE) +
    yaxis_title(FALSE) +
    yaxis_ticks(FALSE) +
    xaxis_title(on = n_param == 1)
}

.mcmc_dens <- function(x,
                       pars = character(),
                       regex_pars = character(),
                       transformations = list(),
                       facet_args = list(),
                       by_chain = FALSE,
                       color_chains = FALSE,
                       geom = c("density", "violin"),
                       probs = c(0.1, 0.5, 0.9),
                       trim = FALSE,
                       ...) {
  x <- prepare_mcmc_array(x, pars, regex_pars, transformations)
  data <- melt_mcmc(x)
  data$Chain <- factor(data$Chain)
  n_param <- num_params(data)

  geom <- match.arg(geom)
  violin <- geom == "violin"
  geom_fun <- if (by_chain) "stat_density" else paste0("geom_", geom)

  if (by_chain || violin) {
    if (!has_multiple_chains(x)) {
      STOP_need_multiple_chains()
    } else {
      n_chains <- num_chains(data)
    }
  }

  aes_mapping <- if (violin) {
    list(x = ~ Chain, y = ~ Value)
  } else {
    list(x = ~ Value)
  }
  geom_args <- list(size = 0.5, na.rm = TRUE)
  if (violin) {
    geom_args[["draw_quantiles"]] <- probs
  } else {
    geom_args[["trim"]] <- trim
  }

  if (by_chain) {
    aes_mapping[["color"]] <- ~ Chain
    aes_mapping[["group"]] <- ~ Chain
    geom_args[["geom"]] <- "line"
    geom_args[["position"]] <- "identity"
  } else {
    geom_args[["fill"]] <- get_color("mid")
    geom_args[["color"]] <- get_color("mid_highlight")
  }

  graph <- ggplot(data, mapping = do.call("aes_", aes_mapping))  +
      do.call(geom_fun, geom_args)

  if (!violin) {
    graph <- graph + dont_expand_x_axis()
  }

  if (by_chain) {
    if (color_chains) {
      scale_color <- scale_color_manual(values = chain_colors(n_chains))
    } else {
      scale_color <- scale_color_manual(
        values = rep(get_color("m"), n_chains),
        guide = "none")
    }
    graph <- graph + scale_color
  }

  if (n_param == 1) {
    graph <-
      graph +
      labs(x = if (violin) "Chain" else levels(data$Parameter),
           y = if (violin) levels(data$Parameter) else NULL)
  } else {
    facet_args[["facets"]] <- ~ Parameter
    if (is.null(facet_args[["scales"]]))
      facet_args[["scales"]] <- "free"
    graph <- graph + do.call("facet_wrap", facet_args)
  }

  graph +
    dont_expand_y_axis(c(0.005, 0)) +
    bayesplot_theme_get() +
    yaxis_text(FALSE) +
    yaxis_ticks(FALSE) +
    yaxis_title(on = n_param == 1 && violin) +
    xaxis_title(on = n_param == 1)
}
