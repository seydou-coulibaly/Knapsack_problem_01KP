# --------------------------------------------------------------------------- #
# Definition Type Noeud
struct Noeud
  num::Int
  item::Array{Int64,1}
  contraintes::Array{Int64,1}
end
# Algorithme Glouton
function glouton(W,p,w)
  capacite = W
  residu = true & (capacite > 0)
  n = length(p)
  solution = zeros(n)
  i = 1
  while residu && i < n+1
    if w[i] <= capacite
      solution[i] = 1
      capacite-= w[i]
      residu = capacite > 0
    end
    i+=1
  end
  return solution
end
function affichageSolution(p,indices,solution)
  n = length(solution)
  x = zeros(n)
  for i =1:n
    ind = indices[i]
    x[ind] = solution[i]
  end
  print(x);println(" ---> ",evaluation(p,solution))
end
function relaxation(W,p,w)
  capacite = W
  residu = true & (capacite > 0)
  n = length(p)
  solution = zeros(n)
  i = 1
  while residu && i < n+1
    if w[i] <= capacite
      solution[i] = 1
      capacite-= w[i]
      residu = capacite > 0
    else
      solution[i] = capacite/w[i]
      capacite = 0
    end
    i+=1
  end
  return solution
end
function trie(arranger)
  n = length(arranger)
  tab = copy(arranger)
  indices  = Array(1:n)
  for i = 1:(n-1)
    j = i+1
    while j <= n
      if tab[i] < tab[j]
      # permuter les valeurs
        x      = tab[j]
        tab[j] = tab[i]
        tab[i] = x
        x = indices[j]
        indices[j] = indices[i]
        indices[i] = x
      end
      # Avancer
      j+=1
    end
  end
  return indices, tab
end
function alphaRelaxation(W,p,w,contraintes)
  capacite = W
  residu = true & (capacite > 0)
  n = length(p)
  solution = zeros(n)
  i = 1
  while residu && i < n+1
    if contraintes[i] != 0
      if w[i] <= capacite
        solution[i] = 1
        capacite-= w[i]
      else
        solution[i] = capacite/w[i]
        capacite = 0
      end
    end
    i+=1
    residu = capacite > 0
  end
  return solution
end
function upperBound0(W,p,w)
  capacite = W
  residu = true & (capacite > 0)
  n = length(p)
  solution = zeros(n)
  i = 1
  while residu && i < n+1
    if w[i] <= capacite
      solution[i] = 1
      capacite-= w[i]
    else
      if i < n
        solution[i+1] = floor(capacite/w[i+1])
        capacite = 0
      else
        solution[i] = capacite/w[i]
        capacite = 0
      end
    end
    i+=1
    residu = capacite > 0
  end
  return evaluation(p,solution)
end
function upperBound1(W,p,w)
  capacite = W
  residu = true & (capacite > 0)
  n = length(p)
  z = 0
  i = 1
  while residu && i < n+1
    if w[i] <= capacite
      z+= p[i]
      capacite-= w[i]
    else
      z+= floor(p[i]-(w[i]-capacite)*(p[i-1]/w[i-1]))
      capacite = 0
    end
    i+=1
    residu = capacite > 0
  end
  return z
end
function upperBound0Contraintes(W,p,w,contraintes)
  capacite = W
  residu = true & (capacite > 0)
  n = length(p)
  solution = zeros(n)
  i = 1
  while residu && i < n+1
    if contraintes[i] != 0
      if w[i] <= capacite
        solution[i] = 1
        capacite-= w[i]
      else
        if i < n
          solution[i+1] = floor(capacite/w[i+1])
          capacite = 0
        else
          solution[i] = capacite/w[i]
          capacite = 0
        end
      end
    end
    i+=1
    residu = capacite > 0
  end
  return evaluation(p,solution)
end
function upperBound1Contraintes(W,p,w,contraintes)
  capacite = W
  residu = true & (capacite > 0)
  n = length(p)
  z = 0
  i = 1
  while residu && i < n+1
    if contraintes[i] != 0
      if w[i] <= capacite
        z+= p[i]
        capacite-= w[i]
      else
        z+= floor(p[i]-(w[i]-capacite)*(p[i-1]/w[i-1]))
        capacite = 0
      end
    end
    i+=1
    residu = capacite > 0
  end
  return z
end
function ukpBound(W,p,w)
  return max(upperBound0(W,p,w),upperBound1(W,p,w))
end
function ukpBoundContraintes(W,p,w,contraintes)
  return max(upperBound0Contraintes(W,p,w,contraintes),upperBound1Contraintes(W,p,w,contraintes))
end
function contrainteGlouton(W,p,w,contraintes)
  capacite = W
  residu = true & (capacite > 0)
  n = length(p)
  solution = zeros(n)
  i = 1
  while residu && i < n+1
    if contraintes[i] != 0
      if w[i] <= capacite
        solution[i] = 1
        capacite-= w[i]
        residu = capacite > 0
      end
    end
    i+=1
  end
  return solution
end
function evaluation(p,solution)
  return dot(p,solution)
end
function branchBound(W,p,w)
  n = length(p)
  xopt = zeros(n)
  zopt = 0
  contraintes = ones(Int,n)
  # Init
  listeNoeud = Noeud[]
  number = 0
  init = Noeud(number,xopt,contraintes)
  push!(listeNoeud,init)
  while length(listeNoeud) > 0
    # Brancher sur le premier noeud de la liste
    noeudCourant = shift!(listeNoeud)
    # print("*****************  ");print(noeudCourant.num);println(" *****************")
    # Borne Duale
    xd = alphaRelaxation(W,p,w,noeudCourant.contraintes)
    zd = evaluation(p,xd)
    # println(" zrelache = ",zd)
    if zd > zopt
      # Borne primale
      x = contrainteGlouton(W,p,w,noeudCourant.contraintes)
      z = evaluation(p,x)
      # println(" zglouton = ",z)
      if z > zopt
        # mis a jour de zopt
        xopt = x
        zopt = z
        # println("Mis à jour de xopt")
        # Mettre les variables vallant 1 à 0
        for i = 1:n
          x = copy(xopt)
          if x[i] == 1
            contrainte = copy(noeudCourant.contraintes)
            x[i] = 0
            contrainte[i] = 0
            # ajouter ce noeud
            number+=1
            # print(" ajout du noeud :",number);print(" ");println(x)
            noeud = Noeud(number,x,contrainte)
            unshift!(listeNoeud,noeud)
          end
        end
      end
    else
      # noeud sondé
    end
  end
  return xopt
end
function branchBoundWithUpper(W,p,w)
  n = length(p)
  xopt = zeros(n)
  zopt = 0
  contraintes = ones(Int,n)
  # Init
  listeNoeud = Noeud[]
  number = 0
  init = Noeud(number,xopt,contraintes)
  push!(listeNoeud,init)
  while length(listeNoeud) > 0
    # Brancher sur le premier noeud de la liste
    noeudCourant = shift!(listeNoeud)
    # print("*****************  ");print(noeudCourant.num);println(" *****************")
    # Borne Duale
    zd = ukpBoundContraintes(W,p,w,noeudCourant.contraintes)
    # print(" & zd = ",zd);println(" & zopt = ",zopt)
    if zd > zopt
      # Borne primale
      x = contrainteGlouton(W,p,w,noeudCourant.contraintes)
      z = evaluation(p,x)
      # println(" zglouton = ",z)
      if z > zopt
        # mis a jour de zopt
        xopt = x
        zopt = z
        # println("Mis à jour de xopt")
        # Mettre les variables vallant 1 à 0
        for i = 1:n
          x = copy(xopt)
          if x[i] == 1
            contrainte = copy(noeudCourant.contraintes)
            x[i] = 0
            contrainte[i] = 0
            # ajouter ce noeud
            number+=1
            # print(" ajout du noeud :",number);print(" ");println(x)
            noeud = Noeud(number,x,contrainte)
            unshift!(listeNoeud,noeud)
          end
        end
      end
    else
      # noeud sondé
    end
  end
  return xopt
end
