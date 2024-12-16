function lss2digraph(lss::Vector{LiteralStatus})
	g = DiGraph(length(lss))

	for i in 1:length(lss)
		for j in lss[i].decision_parents
			add_edge!(g, j, i)
		end
	end
	return g
end

function vizlss(lss::Vector{LiteralStatus})
	minlevel = -1
	dcolors = distinguishable_colors(max_level(lss) - minlevel + 1, [RGB(1, 1, 1), RGB(0, 0, 0)], dropseed = true)
	d = @drawsvg begin
		fontsize(18)
		g = lss2digraph(lss)
		drawgraph(g,
			layout = squaregrid,
			margin = 50,
			edgecurvature = 0.2,
			edgegaps = 30,
			edgestrokeweights = 2,
			vertexlabels = (v) -> "$(v)",
			# vertexshapes = :circle,
            vertexshapes = [lss[v].value ? :square : :circle for v in 1:length(lss)],
			vertexfillcolors = [dcolors[lss[v].decision_level-minlevel+1] for v in 1:length(lss)],
			vertexshapesizes = 25,
			vertexlabeltextcolors = colorant"black",
			edgelabels = (n, s, d, f, t) -> begin
				θ = slope(f, t)
				fontsize(18)
				translate(midpoint(f, t))
				if (θ > π / 2) && (θ < 3π / 2)
					θ -= π
				end
				rotate(θ)
				sethue("black")

				label("CL.$(lss[d].decision_clause)", :s, O, offset = 10)
			end,
		)
	end
	return d, dcolors
end

function vizall(lss::Vector{LiteralStatus}, sat::SATProblem, undefined_variable_num::Vector{Int},fignum)
   vizall(lss, sat, undefined_variable_num;fignum)
   return fignum + 1 
end
function vizall(lss::Vector{LiteralStatus}, sat::SATProblem, undefined_variable_num::Vector{Int};fignum = nothing)
	minlevel = -1
	p1, dcolors = vizlss(lss)
	w = p1.width
	d = p1.height

    if isnothing(fignum)
        d2 = Drawing(2 * w, d + 40*length(sat.clauses))
    else
        d2 = Drawing(2 * w, d + 40*length(sat.clauses), "images/$(fignum).svg")
    end
	# d2 = @drawsvg begin
        translate(w, d )
		placeimage(p1, Point(-w, -d))
		translate(w / 4, 0)
		len = 70
		fontsize(30)
		ldc = length(dcolors)
		text("Levels", Point(-10, -w / 2 - len * ldc + length(dcolors) * len / 2 - len / 2))
		fontsize(50)
		for i in 1:ldc
			sethue(dcolors[end-i+1])
			rect(Point(0, -w / 2 - len * i + length(dcolors) * len / 2), len - 10, len - 10, action = :fill)
			sethue("black")
			text("$(ldc - i+minlevel)", Point(len / 4, -w / 2 - len * i + length(dcolors) * len / 2 + 3 * len / 4))
		end
		fontsize(30)
        text("true literal", Point(w/5, -w / 2 - len * ldc + length(dcolors) * len / 2 - len / 2))
        text("false literal", Point(w/5, -w / 2 - len * ldc + length(dcolors) * len / 2 - len / 2 + 2*len))

        rect(Point(w/2-25, -w / 2 - len * ldc + length(dcolors) * len / 2 - len / 2-35), 50, 50, action=:stroke)
        circle(Point(w/2, -w / 2 - len * ldc + length(dcolors) * len / 2 - len / 2 + 2*len-10), 25, action=:stroke)

		translate(-w / 4, length(sat.clauses)*35/2)
		sethue("black")

		t = Table(length(sat.clauses) + 1, 4, 250, 35) # rows, columns, wide, high
		fontsize(18)
		text("Clause number", t[1], halign = :center, valign = :middle)
		text("True literals", t[2], halign = :center, valign = :middle)
		text("False literals", t[3], halign = :center, valign = :middle)
		text("Clause status", t[4], halign = :center, valign = :middle)

		for i in 1:length(sat.clauses)
			text("CL.$i", t[i+1, 1], halign = :center, valign = :middle)
			text(join(sat.clauses[i].true_literals, ", "), t[i+1, 2], halign = :center, valign = :middle)
			text(join(sat.clauses[i].false_literals, ", "), t[i+1, 3], halign = :center, valign = :middle)

			if undefined_variable_num[i] == -1
				sethue("green")
				text("Satisfied", t[i+1, 4], halign = :center, valign = :middle)
			elseif undefined_variable_num[i] == 0
				sethue("red")
				text("Unsatisfied", t[i+1, 4], halign = :center, valign = :middle)
			else
				sethue("blue")
                udl = [i for i in sat.clauses[i].true_literals ∪ sat.clauses[i].false_literals if lss[i].decision_level == -1]
				text("Literal $(udl) to be decided", t[i+1, 4], halign = :center, valign = :middle)
			end
            sethue("black")


		end
	# end 2 * w d+ 40*length(sat.clauses) "images/$(fignum).svg"
    finish()
	return d2
end
