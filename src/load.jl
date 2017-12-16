# ------------------------------------------------------------------------------
#                     LOAD FILE
# ------------------------------------------------------------------------------
function loadPb(fname)
  f = open(fname)
  # lecture du nbre de variables (n)
  n = parse.(Int,split(readline(f)))
  n = n[1]
  # lecture du poids max (W)
  W = parse.(Int,split(readline(f)))
  W = W[1]
  # lecture des profits p[n]
  p = zeros(Int,n)
  i = 1
  for value in split(readline(f))
    valeur = parse(Int,value)
    p[i] = valeur
    i+=1
  end

  # lecture des poids w[n]
  w = zeros(Int,n)
  i = 1
  for value in split(readline(f))
    valeur = parse(Int,value)
    w[i] = valeur
    i+=1
  end
  close(f)
  return W,p,w
end
function loadPbM(fname)
  f = open(fname)
  M = zeros(Int,2)
  i = 1
  for value in split(readline(f))
    valeur = parse(Int,value)
    M[i] = valeur
    i+=1
  end
  n = M[1]
  W = M[2]
  p = zeros(Int,n)
  w = zeros(Int,n)
  for i = 1:n
    j =1
    for value in split(readline(f))
      valeur = parse(Int,value)
      M[j] = valeur
      j+=1
    end
    p[i] = M[1]
    w[i] = M[2]
  end
  close(f)
  return W,p,w
end
