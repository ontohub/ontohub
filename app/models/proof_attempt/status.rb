module ProofAttempt::Status
  extend ActiveSupport::Concern

  # SZS Statuses
  SOLVED = {
    'SOL' => 'Solved'
  }

  DEDUCTIVE = {
    'SAT' => 'Satisfiable',
    'THM' => 'Theorem',
    'EQV' => 'Equivalent',
    'WTH' => 'WeakerTheorem',
    'TAC' => 'TautologousConclusion',
    'TAU' => 'Tautology',
    'CAX' => 'ContradictoryAxioms',
    'WCT' => 'WeakerCounterTheorem',
    'NOC' => 'NoConsequence',
  }

  PRESERVING = {
    'SAB' => 'SatisfiabilityBijection',
    'SAM' => 'SatisfiabilityMapping',
    'SAR' => 'SatisfiabilityPartialMapping',
    'SAP' => 'SatisfiabilityPreserving',
    'CSP' => 'CounterSatisfiabilityPreserving',
    'CSR' => 'CounterSatisfiabilityPartialMapping',
  }

  UNSOLVED = {
    'USD' => 'Unsolved',
    'OPN' => 'Open',
    'UNK' => 'Unknown',
    'ASS' => 'Assumed',
    'STP' => 'Stopped',
    'ERR' => 'Error',
    'INE' => 'InputError',
    'OSE' => 'OSError',
    'FOR' => 'Forced',
    'USR' => 'User',
    'RSO' => 'ResourceOut',
    'TMO' => 'Timeout',
    'GUP' => 'GaveUp'
  }

  OUTPUT = {
    'Sln' => 'Solution',
    'Der' => 'Derivation',
    'Prf' => 'Proof',
    'Ref' => 'Refutation',
    'CRf' => 'CNFRefutation',
    'Mod' => 'Model',
    'FMo' => 'FiniteModel',
    'IMo' => 'InfiniteModel',
    'Sat' => 'Saturation',
    'Ass' => 'Assurance',
    'Non' => 'None'
  }

  STATUSES_HASH = Hash[
    *[SOLVED, DEDUCTIVE, PRESERVING, UNSOLVED, OUTPUT].map(&:to_a).flatten]

  STATUSES = STATUSES_HASH.keys

  module ClassMethods
    def decisive_status?(status)
      [SOLVED, DEDUCTIVE, PRESERVING].any? do |category|
        category.keys.include?(status)
      end
    end
  end
end
