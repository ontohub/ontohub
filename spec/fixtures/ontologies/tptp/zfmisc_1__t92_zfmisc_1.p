%------------------------------------------------------------------------------
% File     : zfmisc_1__t92_zfmisc_1

% Syntax   : Number of formulae    :    7 (   4 unit)
%            Number of atoms       :   10 (   0 equality)
%            Maximal formula depth :    5 (   3 average)
%            Number of connectives :    5 (   2 ~  ;   0  |;   0  &)
%                                         (   0 <=>;   3 =>;   0 <=)
%                                         (   0 <~>;   0 ~|;   0 ~&)
%            Number of predicates  :    4 (   1 propositional; 0-2 arity)
%            Number of functors    :    1 (   0 constant; 1-1 arity)
%            Number of variables   :   10 (   1 singleton;   8 !;   2 ?)
%            Maximal term depth    :    2 (   1 average)
%------------------------------------------------------------------------------
fof(reflexivity_r1_tarski,axiom,(
    ! [A,B] : subset(A,A) )).

fof(antisymmetry_r2_hidden,axiom,(
    ! [A,B] : 
      ( in(A,B)
     => ~ in(B,A) ) )).

fof(dt_k3_tarski,axiom,(
    $true )).

fof(rc1_xboole_0,axiom,(
    ? [A] : empty(A) )).

fof(rc2_xboole_0,axiom,(
    ? [A] : ~ empty(A) )).

fof(t92_zfmisc_1,conjecture,(
    ! [A,B] : 
      ( in(A,B)
     => subset(A,union(B)) ) )).

fof(l50_zfmisc_1,axiom,(
    ! [A,B] : 
      ( in(A,B)
     => subset(A,union(B)) ) )).
%------------------------------------------------------------------------------
