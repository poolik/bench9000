# Copyright 2008 the V8 project authors. All rights reserved.
# Copyright 1996 John Maloney and Mario Wolczko.

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


# This implementation of the DeltaBlue benchmark is derived
# from the Smalltalk implementation by John Maloney and Mario
# Wolczko. Some parts have been translated directly, whereas
# others have been modified more aggresively to make it feel
# more like a JavaScript program.

# Transliterated directly to Ruby by Chris Seaton

def alert(message)
  puts message
  abort
end

#DeltaBlue = BenchmarkSuite.new('DeltaBlue', [66118], [
#  Benchmark.new('DeltaBlue', true, false, deltaBlue)
#])

#  A JavaScript implementation of the DeltaBlue constraint-solving
#  algorithm, as described in:
# 
#  "The DeltaBlue Algorithm: An Incremental Constraint Hierarchy Solver"
#    Bjorn N. Freeman-Benson and John Maloney
#    January 1990 Communications of the ACM,
#    also available as University of Washington TR 89-08-06.
# 
#  Beware: this benchmark is written in a grotesque style where
#  the constraint model is built by side-effects from constructors.
#  I've kept it this way to avoid deviating too much from the original
#  implementation.


#  --- O b j e c t   M o d e l --- */

class OrderedCollection

  def initialize
    @elms = Array.new()
  end

  def add(elm)
    @elms.push(elm)
  end

  def at(index)
    return @elms[index]
  end

  def size()
    return @elms.length
  end

  def removeFirst()
    return @elms.pop()
  end

  def remove(elm)
    index = 0
    skipped = 0
    i = 0
    while i < @elms.length
      value = @elms[i]
      if (value != elm)
        @elms[index] = value
        index+= 1
      else
        skipped+= 1
      end
      i += 1
    end
    i = 0
    while i < skipped
      @elms.pop()
      i += 1
    end
  end

end

#  --- *
#  S t r e n g t h
#  --- */

# *
#  Strengths are used to measure the relative importance of constraints.
#  New strengths may be inserted in the strength hierarchy without
#  disrupting current constraints.  Strengths cannot be created outside
#  this class, so pointer comparison can be used for value comparison.
# /

class Strength

  attr_reader :strengthValue

  def initialize(strengthValue, name)
    @strengthValue = strengthValue
    @name = name
  end

  def self.stronger(s1, s2)
    return s1.strengthValue < s2.strengthValue
  end

  def self.weaker(s1, s2)
    return s1.strengthValue > s2.strengthValue
  end

  def self.weakestOf(s1, s2)
    return weaker(s1, s2) ? s1 : s2
  end

  def self.strongest(s1, s2)
    return stronger(s1, s2) ? s1 : s2
  end

  def nextWeaker
    case (@strengthValue)
      when 0; return WEAKEST
      when 1; return WEAK_DEFAULT
      when 2; return NORMAL
      when 3; return STRONG_DEFAULT
      when 4; return PREFERRED
      when 5; return REQUIRED
    end
  end

  # Strength constants.
  REQUIRED        = new(0, "required")
  STONG_PREFERRED = new(1, "strongPreferred")
  PREFERRED       = new(2, "preferred")
  STRONG_DEFAULT  = new(3, "strongDefault")
  NORMAL          = new(4, "normal")
  WEAK_DEFAULT    = new(5, "weakDefault")
  WEAKEST         = new(6, "weakest")

end

#  --- *
#  C o n s t r a i n t
#  --- */

# *
#  An abstract class representing a system-maintainable relationship
#  (or "constraint") between a set of variables. A constraint supplies
#  a strength instance variable; concrete subclasses provide a means
#  of storing the constrained variables and other information required
#  to represent a constraint.
# /

class Constraint

  attr_reader :strength

  def initialize(strength)
    @strength = strength
  end

  # *
  #  Activate this constraint and attempt to satisfy it.
  # /
  def addConstraint
    addToGraph()
    $planner.incrementalAdd(self)
  end

  # *
  #  Attempt to find a way to enforce this constraint. If successful,
  #  record the solution, perhaps modifying the current dataflow
  #  graph. Answer the constraint that this constraint overrides, if
  #  there is one, or nil, if there isn't.
  #  Assume: I am not already satisfied.
  # /
  def satisfy(mark)
    chooseMethod(mark)
    if (!isSatisfied())
      alert("Could not satisfy a required constraint!") if (@strength == Strength::REQUIRED)
      return nil
    end
    markInputs(mark)
    out = output()
    overridden = out.determinedBy
    overridden.markUnsatisfied() if (overridden != nil)
    out.determinedBy = self
    alert("Cycle encountered") if (!$planner.addPropagate(self, mark))
    out.mark = mark
    return overridden
  end

  def destroyConstraint
    if (isSatisfied())
      $planner.incrementalRemove(self)
    else
      removeFromGraph()
    end
  end

  # *
  #  Normal constraints are not input constraints.  An input constraint
  #  is one that depends on external state, such as the mouse, the
  #  keybord, a clock, or some arbitraty piece of imperative code.
  # /
  def isInput
    return false
  end

end

#  --- *
#  U n a r y   C o n s t r a i n t
#  --- */

# *
#  Abstract superclass for constraints having a single possible output
#  variable.
# /

class UnaryConstraint < Constraint

  def initialize(v, strength)
    super(strength)
    @myOutput = v
    @satisfied = false
    addConstraint()
  end

  #UnaryConstraint.inheritsFrom(Constraint)

  # *
  #  Adds this constraint to the constraint graph
  # /
  def addToGraph
    @myOutput.addConstraint(self)
    @satisfied = false
  end

  # *
  #  Decides if this constraint can be satisfied and records that
  #  decision.
  # /
  def chooseMethod(mark)
    @satisfied = (@myOutput.mark != mark) && Strength::stronger(@strength, @myOutput.walkStrength)
  end

  # *
  #  Returns true if this constraint is satisfied in the current solution.
  # /
  def isSatisfied
    return @satisfied
  end

  def markInputs(mark)
    # has no inputs
  end

  # *
  #  Returns the current output variable.
  # /
  def output
    return @myOutput
  end

  # *
  #  Calculate the walkabout strength, the stay flag, and, if it is
  #  'stay', the value for the current output of this constraint. Assume
  #  this constraint is satisfied.
  # /
  def recalculate
    @myOutput.walkStrength = @strength
    @myOutput.stay = !isInput()
    execute() if (@myOutput.stay)# Stay optimization
  end

  # *
  #  Records that this constraint is unsatisfied
  # /
  def markUnsatisfied
    @satisfied = false
  end

  def inputsKnown(x)
    return true
  end

  def removeFromGraph
    @myOutput.removeConstraint(self) if (@myOutput != nil)
    @satisfied = false
  end

end

#  --- *
#  S t a y   C o n s t r a i n t
#  --- */

# *
#  Variables that should, with some level of preference, stay the same.
#  Planners may exploit the fact that instances, if satisfied, will not
#  change their output during plan execution.  This is called "stay
#  optimization".
# /

class StayConstraint < UnaryConstraint

  def initialize(v, str)
    super(v, str)
  end

  #StayConstraint.inheritsFrom(UnaryConstraint)

  def execute
    # Stay constraints do nothing
  end

end

#  --- *
#  E d i t   C o n s t r a i n t
#  --- */

# *
#  A unary input constraint used to mark a variable that the client
#  wishes to change.
# /

class EditConstraint < UnaryConstraint

  def initialize(v, str)
    super(v, str)
  end

  #EditConstraint.inheritsFrom(UnaryConstraint)

  # *
  #  Edits indicate that a variable is to be changed by imperative code.
  # /
  def isInput
    return true
  end

  def execute
    # Edit constraints do nothing
  end

end

#  --- *
#  B i n a r y   C o n s t r a i n t
#  --- */

module Direction
  NONE = 0
  FORWARD = 1
  BACKWARD = -1
end

class BinaryConstraint < Constraint

  # *
  #  Abstract superclass for constraints having two possible output
  #  variables.
  # /
  def initialize(var1, var2, strength)
    super(strength)
    @v1 = var1
    @v2 = var2
    @direction = Direction::NONE
    addConstraint()
  end

  #BinaryConstraint.inheritsFrom(Constraint)

  # *
  #  Decides if this constraint can be satisfied and which way it
  #  should flow based on the relative strength of the variables related,
  #  and record that decision.
  # /
  def chooseMethod(mark)
    if (@v1.mark == mark)
      @direction = (@v2.mark != mark && Strength::stronger(@strength, @v2.walkStrength)) ? Direction::FORWARD : Direction::NONE
      return
    end
    if (@v2.mark == mark)
      @direction = (@v1.mark != mark && Strength::stronger(@strength, @v1.walkStrength)) ? Direction::BACKWARD : Direction::NONE
      return
    end
    if (Strength::weaker(@v1.walkStrength, @v2.walkStrength))
      @direction = Strength::stronger(@strength, @v1.walkStrength) ? Direction::BACKWARD : Direction::NONE
    else
      @direction = Strength::stronger(@strength, @v2.walkStrength) ? Direction::FORWARD : Direction::BACKWARD
    end
  end

  # *
  #  Add this constraint to the constraint graph
  # /
  def addToGraph
    @v1.addConstraint(self)
    @v2.addConstraint(self)
    @direction = Direction::NONE
  end

  # *
  #  Answer true if this constraint is satisfied in the current solution.
  # /
  def isSatisfied
    return @direction != Direction::NONE
  end

  # *
  #  Mark the input variable with the given mark.
  # /
  def markInputs(mark)
    input().mark = mark
  end

  # *
  #  Returns the current input variable
  # /
  def input
    return (@direction == Direction::FORWARD) ? @v1 : @v2
  end

  # *
  #  Returns the current output variable
  # /
  def output
    return (@direction == Direction::FORWARD) ? @v2 : @v1
  end

  # *
  #  Calculate the walkabout strength, the stay flag, and, if it is
  #  'stay', the value for the current output of this
  #  constraint. Assume this constraint is satisfied.
  # /
  def recalculate
    ihn = input()
    out = output()
    out.walkStrength = Strength::weakestOf(@strength, ihn.walkStrength)
    out.stay = ihn.stay
    execute() if (out.stay)
  end

  # *
  #  Record the fact that this constraint is unsatisfied.
  # /
  def markUnsatisfied
    @direction = Direction::NONE
  end

  def inputsKnown(mark)
    i = input()
    return i.mark == mark || i.stay || i.determinedBy == nil
  end

  def removeFromGraph
    @v1.removeConstraint(self) if (@v1 != nil)
    @v2.removeConstraint(self) if (@v2 != nil)
    @direction = Direction::NONE
  end

end

#  --- *
#  S c a l e   C o n s t r a i n t
#  --- */

# *
#  Relates two variables by the linear scaling relationship: "v2 =
#  (v1 * scale) + offset". Either v1 or v2 may be changed to maintain
#  this relationship but the scale factor and offset are considered
#  read-only.
# /

class ScaleConstraint < BinaryConstraint

  def initialize(src, scale, offset, dest, strength)
    @direction = Direction::NONE
    @scale = scale
    @offset = offset
    super(src, dest, strength)
  end

  #ScaleConstraint.inheritsFrom(BinaryConstraint)

  # *
  #  Adds this constraint to the constraint graph.
  # /
  def addToGraph
    super
    @scale.addConstraint(self)
    @offset.addConstraint(self)
  end

  def removeFromGraph
    super
    @scale.removeConstraint(self) if (@scale != nil)
    @offset.removeConstraint(self) if (@offset != nil)
  end

  def markInputs(mark)
    super(mark)
    @scale.mark = @offset.mark = mark
  end

  # *
  #  Enforce this constraint. Assume that it is satisfied.
  # /
  def execute
    if (@direction == Direction::FORWARD)
      @v2.value = @v1.value * @scale.value + @offset.value
    else
      @v1.value = (@v2.value - @offset.value) / @scale.value
    end
  end

  # *
  #  Calculate the walkabout strength, the stay flag, and, if it is
  #  'stay', the value for the current output of this constraint. Assume
  #  this constraint is satisfied.
  # /
  def recalculate
    ihn = input()
    out = output()
    out.walkStrength = Strength.weakestOf(@strength, ihn.walkStrength)
    out.stay = ihn.stay && @scale.stay && @offset.stay
    execute() if (out.stay)
  end

end

#  --- *
#  E q u a l i t  y   C o n s t r a i n t
#  --- */

# *
#  Constrains two variables to have the same value.
# /

class EqualityConstraint < BinaryConstraint

  def initialize(var1, var2, strength)
    super(var1, var2, strength)
  end

  #EqualityConstraint.inheritsFrom(BinaryConstraint)

  # *
  #  Enforce this constraint. Assume that it is satisfied.
  # /
  def execute
    output().value = input().value
  end

end

#  --- *
#  V a r i a b l e
#  --- */

# *
#  A constrained variable. In addition to its value, it maintain the
#  structure of the constraint graph, the current dataflow graph, and
#  various parameters of interest to the DeltaBlue incremental
#  constraint solver.
# */

class Variable

  attr_accessor :mark, :walkStrength, :determinedBy, :stay, :value, :constraints

  def initialize(name, initialValue = nil)
    @value = initialValue || 0
    @constraints = OrderedCollection.new()
    @determinedBy = nil
    @mark = 0
    @walkStrength = Strength::WEAKEST
    @stay = true
    @name = name
  end

  # *
  #  Add the given constraint to the set of all constraints that refer
  #  this variable.
  # /
  def addConstraint(c)
    @constraints.add(c)
  end

  # *
  #  Removes all traces of c from this variable.
  # /
  def removeConstraint(c)
    @constraints.remove(c)
    @determinedBy = nil if (@determinedBy == c)
  end

end

#  --- *
#  P l a n n e r
#  --- */

# *
#  The DeltaBlue planner
# /

class Planner

  def initialize()
    @currentMark = 0
  end

  # *
  #  Attempt to satisfy the given constraint and, if successful,
  #  incrementally update the dataflow graph.  Details: If satifying
  #  the constraint is successful, it may override a weaker constraint
  #  on its output. The algorithm attempts to resatisfy that
  #  constraint using some other method. This process is repeated
  #  until either a) it reaches a variable that was not previously
  #  determined by any constraint or b) it reaches a constraint that
  #  is too weak to be satisfied using any of its methods. The
  #  variables of constraints that have been processed are marked with
  #  a unique mark value so that we know where we've been. This allows
  #  the algorithm to avoid getting into an infinite loop even if the
  #  constraint graph has an inadvertent cycle.
  # /
  def incrementalAdd(c)
    mark = newMark()
    overridden = c.satisfy(mark)
    while (overridden != nil)
      overridden = overridden.satisfy(mark)
    end
  end

  # *
  #  Entry point for retracting a constraint. Remove the given
  #  constraint and incrementally update the dataflow graph.
  #  Details: Retracting the given constraint may allow some currently
  #  unsatisfiable downstream constraint to be satisfied. We therefore collect
  #  a list of unsatisfied downstream constraints and attempt to
  #  satisfy each one in turn. This list is traversed by constraint
  #  strength, strongest first, as a heuristic for avoiding
  #  unnecessarily adding and then overriding weak constraints.
  #  Assume: c is satisfied.
  # /
  def incrementalRemove(c)
    out = c.output()
    c.markUnsatisfied()
    c.removeFromGraph()
    unsatisfied = removePropagateFrom(out)
    strength = Strength::REQUIRED
    while true
      i = 0
      while i < unsatisfied.size()
        u = unsatisfied.at(i)
        incrementalAdd(u) if (u.strength == strength)
        i += 1
      end
      strength = strength.nextWeaker()
      break unless (strength != Strength::WEAKEST)
    end
  end

  # *
  #  Select a previously unused mark value.
  # /
  def newMark
    return @currentMark += 1
  end

  # *
  #  Extract a plan for resatisfaction starting from the given source
  #  constraints, usually a set of input constraints. This method
  #  assumes that stay optimization is desired; the plan will contain
  #  only constraints whose output variables are not stay. Constraints
  #  that do no computation, such as stay and edit constraints, are
  #  not included in the plan.
  #  Details: The outputs of a constraint are marked when it is added
  #  to the plan under construction. A constraint may be appended to
  #  the plan when all its input variables are known. A variable is
  #  known if either a) the variable is marked (indicating that has
  #  been computed by a constraint appearing earlier in the plan), b)
  #  the variable is 'stay' (i.e. it is a constant at plan execution
  #  time), or c) the variable is not determined by any
  #  constraint. The last provision is for past states of history
  #  variables, which are not stay but which are also not computed by
  #  any constraint.
  #  Assume: sources are all satisfied.
  # /
  def makePlan(sources)
    mark = newMark()
    plan = Plan.new()
    todo = sources
    while (todo.size() > 0)
      c = todo.removeFirst()
      if (c.output().mark != mark && c.inputsKnown(mark))
        plan.addConstraint(c)
        c.output().mark = mark
        addConstraintsConsumingTo(c.output(), todo)
      end
    end
    return plan
  end

  # *
  #  Extract a plan for resatisfying starting from the output of the
  #  given constraints, usually a set of input constraints.
  # /
  def extractPlanFromConstraints(constraints)
    sources = OrderedCollection.new()
    i = 0
    while i < constraints.size()
      c = constraints.at(i)
      sources.add(c) if (c.isInput() && c.isSatisfied())
      i += 1
    end
    return makePlan(sources)
  end

  # *
  #  Recompute the walkabout strengths and stay flags of all variables
  #  downstream of the given constraint and recompute the actual
  #  values of all variables whose stay flag is true. If a cycle is
  #  detected, remove the given constraint and answer
  #  false. Otherwise, answer true.
  #  Details: Cycles are detected when a marked variable is
  #  encountered downstream of the given constraint. The sender is
  #  assumed to have marked the inputs of the given constraint with
  #  the given mark. Thus, encountering a marked node downstream of
  #  the output constraint means that there is a path from the
  #  constraint's output to one of its inputs.
  # /
  def addPropagate(c, mark)
    todo = OrderedCollection.new()
    todo.add(c)
    while (todo.size() > 0)
      d = todo.removeFirst()
      if (d.output().mark == mark)
        incrementalRemove(c)
        return false
      end
      d.recalculate()
      addConstraintsConsumingTo(d.output(), todo)
    end
    return true
  end


  # *
  #  Update the walkabout strengths and stay flags of all variables
  #  downstream of the given constraint. Answer a collection of
  #  unsatisfied constraints sorted in order of decreasing strength.
  # /
  def removePropagateFrom(out)
    out.determinedBy = nil
    out.walkStrength = Strength::WEAKEST
    out.stay = true
    unsatisfied = OrderedCollection.new()
    todo = OrderedCollection.new()
    todo.add(out)
    while (todo.size() > 0)
      v = todo.removeFirst()
      i = 0
      while i < v.constraints.size()
        c = v.constraints.at(i)
        unsatisfied.add(c) if (!c.isSatisfied())
        i += 1
      end
      determining = v.determinedBy
      i = 0
      while i < v.constraints.size()
        next_ = v.constraints.at(i)
        if (next_ != determining && next_.isSatisfied())
          next_.recalculate()
          todo.add(next_.output())
        end
        i += 1
      end
    end
    return unsatisfied
  end

  def addConstraintsConsumingTo(v, coll)
    determining = v.determinedBy
    cc = v.constraints
    i = 0
    while i < cc.size()
      c = cc.at(i)
      coll.add(c) if (c != determining && c.isSatisfied())
      i += 1
    end
  end

end

#  --- *
#  P l a n
#  --- */

# *
#  A Plan is an ordered list of constraints to be executed in sequence
#  to resatisfy all currently satisfiable constraints in the face of
#  one or more changing inputs.
# /

class Plan

  def initialize()
    @v = OrderedCollection.new()
  end

  def addConstraint(c)
    @v.add(c)
  end

  def size
    return @v.size()
  end

  def constraintAt(index)
    return @v.at(index)
  end

  def execute
    i = 0
    while i < size()
      c = constraintAt(i)
      c.execute()
      i += 1
    end
  end

end

#  --- *
#  M a i n
#  --- */

# *
#  This is the standard DeltaBlue benchmark. A long chain of equality
#  constraints is constructed with a stay constraint on one end. An
#  edit constraint is then added to the opposite end and the time is
#  measured for adding and removing this constraint, and extracting
#  and executing a constraint satisfaction plan. There are two cases.
#  In case 1, the added constraint is stronger than the stay
#  constraint and values must propagate down the entire length of the
#  chain. In case 2, the added constraint is weaker than the stay
#  constraint so it cannot be accomodated. The cost in this case is,
#  of course, very low. Typical situations lie somewhere between these
#  two extremes.
# /
def chainTest(n)
  $planner = Planner.new()
  prev = nil
  first = nil
  last = nil

  # Build chain of n equality constraints
  i = 0
  while i <= n
    name = "v" + i.to_s
    v = Variable.new(name)
    if (prev != nil)
      EqualityConstraint.new(prev, v, Strength::REQUIRED)
    end
    first = v if (i == 0)
    last = v if (i == n)
    prev = v
    i += 1
  end

  StayConstraint.new(last, Strength::STRONG_DEFAULT)
  edit = EditConstraint.new(first, Strength::PREFERRED)
  edits = OrderedCollection.new()
  edits.add(edit)
  plan = $planner.extractPlanFromConstraints(edits)
  i = 0
  while i < 100
    first.value = i
    plan.execute()
    alert("Chain test failed.") if (last.value != i)
    i += 1
  end
end

# *
#  This test constructs a two sets of variables related to each
#  other by a simple linear transformation (scale and offset). The
#  time is measured to change a variable on either side of the
#  mapping and to change the scale and offset factors.
# /
def projectionTest(n)
  $planner = Planner.new()
  scale = Variable.new("scale", 10)
  offset = Variable.new("offset", 1000)
  src = nil
  dst = nil

  dests = OrderedCollection.new()
  i = 0
  while i < n
    src = Variable.new("src" + i.to_s, i)
    dst = Variable.new("dst" + i.to_s, i)
    dests.add(dst)
    StayConstraint.new(src, Strength::NORMAL)
    ScaleConstraint.new(src, scale, offset, dst, Strength::REQUIRED)
    i += 1
  end

  change(src, 17)
  alert("Projection 1 failed") if (dst.value != 1170)
  change(dst, 1050)
  alert("Projection 2 failed") if (src.value != 5)
  change(scale, 5)
  i = 0
  while i < n - 1
    alert("Projection 3 failed") if (dests.at(i).value != i * 5 + 1000)
    i += 1
  end
  change(offset, 2000)
  i = 0
  while i < n - 1
    alert("Projection 4 failed") if (dests.at(i).value != i * 5 + 2000)
    i += 1
  end
end

def change(v, newValue)
  edit = EditConstraint.new(v, Strength::PREFERRED)
  edits = OrderedCollection.new()
  edits.add(edit)
  plan = $planner.extractPlanFromConstraints(edits)
  i = 0
  while i < 10
    v.value = newValue
    plan.execute()
    i += 1
  end
  edit.destroyConstraint()
end

# Global variable holding the current planner.
$planner = nil

def deltaBlue()
  chainTest(100)
  projectionTest(100)
end

def harness_input
  10_000
end

def harness_sample(input)
  chainTest(input)
  projectionTest(input)
end

def harness_verify(output)
  # Self-verifies
  true
end

require 'bench/harness'
