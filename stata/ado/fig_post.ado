*! fig_post 1.0  18nov2026  E. Tolani
*! Stores one estimate for a figure in the frame fig_estimates: the coefficient,
*! its standard error, p-value, stars, 95% interval and the number of observations.
*! By default the numbers come from r(table) of the last estimation, which is what
*! the estimation command reports (t distribution when the model has residual
*! degrees of freedom). The options b(), se(), lo(), hi() and p() replace them,
*! for intervals that come from a bootstrap. Run it right after the estimation.
program define fig_post
    version 18
    syntax , FIGure(string) PANel(string) LABel(string) COEF(string) ///
        [B(string) SE(string) LO(string) HI(string) P(string) ORDer(integer 0)]

    * Copy r(table) first: later commands overwrite r()
    tempname T
    capture matrix `T' = r(table)
    local has_table = (_rc == 0)

    capture confirm frame fig_estimates
    if _rc {
        frame create fig_estimates str12 figure str60 panel str60 var_name ///
            int order double(coef se ci_low ci_high p) str3 stars long N str32 term
    }

    * Values from r(table), unless all five are given
    if "`b'" == "" | "`se'" == "" | "`lo'" == "" | "`hi'" == "" | "`p'" == "" {
        capture assert `has_table'
        if _rc {
            display as error "fig_post: no r(table); run it right after the estimation"
            exit 301
        }
        local j = colnumb(`T', "`coef'")
        if missing(`j') {
            display as error "fig_post: `coef' not found in r(table)"
            exit 111
        }
        foreach s in b se ll ul pvalue {
            local v_`s' = `T'[rownumb(`T', "`s'"), `j']
        }
    }
    if "`b'"  != "" local v_b      = `b'
    if "`se'" != "" local v_se     = `se'
    if "`lo'" != "" local v_ll     = `lo'
    if "`hi'" != "" local v_ul     = `hi'
    if "`p'"  != "" local v_pvalue = `p'

    local stars = cond(`v_pvalue' < 0.01, "***", cond(`v_pvalue' < 0.05, "**", ///
                  cond(`v_pvalue' < 0.1, "*", "")))
    frame post fig_estimates ("`figure'") ("`panel'") ("`label'") (`order') ///
        (`v_b') (`v_se') (`v_ll') (`v_ul') (`v_pvalue') ("`stars'") (e(N)) ("`coef'")
end
