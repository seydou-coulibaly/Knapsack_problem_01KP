# ------------------------------------------------------------------------------
include("modelUKP.jl")
include("branchBound.jl")
include("load.jl")
# Proceeding to the optimization
solverSelected = GLPKSolverMIP()
# ------------------------------------------------------------------------------
#                     MAIN
# ------------------------------------------------------------------------------
function chargement(file)
  # load file
  W,p,w = loadPb(file)
  n = length(p)
  indices = Array(1:n)
  n = length(p)
  println("\nNbre d'items = ",n)
  # Arragement utilites
  tab = zeros(n)
  for i=1:n
    tab[i] = p[i]/w[i]
  end
  if !issorted(tab,rev=true)
    # re-arranger tableau des utilites
    indices, arranger = trie(tab)
    # println(searchsorted(tab,55, rev=true))
    profit = copy(p)
    weight = copy(w)
    for i = 1:n
      ind = indices[i]
      profit[i] = p[ind]
      weight[i] = w[ind]
    end
    p = profit
    w = weight
  end
  return indices,W,p,w
end
# ----------------------  Fonction utilse  -------------------------------------
function bornes(W,p,w,indices)
  println("***********************************")
  # ----------------------- Pimale/Duale  ----------------------------------------
  x = glouton(W,p,w)
  print("Primale = ");affichageSolution(p,indices,x)
  xopt = relaxation(W,p,w)
  print("Duale   = ");affichageSolution(p,indices,xopt)
  # ----------------------- Improved Bound  --------------------------------------
  borne = ukpBound(W,p,w)
  println("Improved Bound   = ",borne)
  println()
end
function ukpBranchBound(W,p,w,indices)
  tic  = time()
  xopt = branchBound(W,p,w)
  tac  = time()
  println()
  println(" ------- Branch and Bound  -------")
  affichageSolution(p,indices,xopt)
  print("\n\tTime (UKP) = ",round((tac-tic),3));println(" Secondes")
end
function ukp(typeResolution,instance)
  indices,W,p,w = chargement(instance)
  bornes(W,p,w,indices)
  if typeResolution == "GLPK-JUMP"
    tic = time()
    xopt = glpk_jump(W,p,w)
    affichageSolution(p,indices,xopt)
    tac = time()
    print("\n\tTime (UKP) = ",round((tac-tic),3));println(" Secondes")
  elseif typeResolution == "UKPB"
    tic = time()
    println(" ------- Branch and Bound with improved bound -------")
    xopt = branchBoundWithUpper(W,p,w)
    affichageSolution(p,indices,xopt)
    tac = time()
    print("\n\tTime (UKP) = ",round((tac-tic),3));println(" Secondes")
  else
  ukpBranchBound(W,p,w,indices)
  end
end
# ----------------------  Résolution  ------------------------------------------
# instance = "../data/kp$(7)a.dat"
# ukp("GLPK-JUMP",instance)
