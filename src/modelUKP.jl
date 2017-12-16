# =========================================================================== #

# Using the following packages
using JuMP, GLPKMathProgInterface

function setUKP(solverSelected,W,p,w)
  n = length(p)
  ip = Model(solver=solverSelected)
  #Variables definitions
  @variable(ip, X[1:n],Bin)
  #Objectives functions
  @objective(ip, Max,
                    sum(p[i] * X[i] for i=1:n)
                    )
  #Constraints of problem
  @constraint(ip, dot(X,w) <= W)

  return ip, X
end

#-------------------------------------------------------------------------------
# Proceeding to the optimization
solverSelected = GLPKSolverMIP()

function glpk_jump(W,p,w)
  # GLPK et JUMP
  #println()
  #println(" ------- GLPK-JUMP  -------")
  x = zeros(length(p))
  ip,X = setUKP(solverSelected,W,p,w)
  println("The optimization problem to be solved is:")
  print(ip)
  println("Solving...");
  status = solve(ip)
  # Displaying the results
  if status == :Optimal
    #println("status = ", status)
    x = getvalue(X)
  end
  #println()
  return x
end
