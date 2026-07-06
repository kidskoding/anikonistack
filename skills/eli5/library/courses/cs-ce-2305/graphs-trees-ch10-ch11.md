---
course: CS/CE 2305 Discrete Mathematics
module: Chapter 10 (Graphs 10.1-10.5) & Chapter 11 (Trees 11.1, 11.3-11.4)
source: pasted content — Final Exam Review Spring 2026
date: 2026-05-11
tags: [data-structures, algorithms, graphs, trees, discrete-math]
---

# CS/CE 2305 — Ch 10 (Graphs) & Ch 11 (Trees)
## Comprehensive ELI5 Final Exam Guide

Source: pasted content (CS/CE 2305 Final Exam Review, Spring 2026)

---

# ═══════════════════════════════════
# CHAPTER 10: GRAPHS (10.1 – 10.5)
# ═══════════════════════════════════

---

## 10.1 — Graph Models & Types of Graphs

### The Analogy
Imagine a map of cities connected by roads. Cities = **vertices** (dots). Roads = **edges** (lines). A graph is just a formal way to represent "things" and "connections between things." That's it.

### What's Actually Happening

A graph G = (V, E) has:
- **V** = set of vertices
- **E** = set of edges

**Types of graphs — exam source material:**

| Type | What makes it special |
|---|---|
| **Simple graph** | At most one edge between any two vertices; no self-loops; undirected |
| **Multigraph** | Multiple edges allowed between same pair; no self-loops; undirected |
| **Pseudograph** | Multiple edges AND self-loops allowed; undirected |
| **Simple directed graph** | Edges are arrows; at most one directed edge between any ordered pair |
| **Directed multigraph** | Directed + multiple edges between same ordered pair allowed |

**Memory trick:** Simple = strictest. Each relaxation adds a word to the name.

Self-loop = edge from vertex back to itself.

---

## 10.2 — Graph Terminology & Special Graph Types

### The Analogy
"Degree" of a vertex = how many roads touch that city. Degree 4 means 4 roads.

### What's Actually Happening

**Degree:**
- Undirected: **deg(v)** = edges incident to v (self-loop counts twice)
- Directed:
  - **deg⁻(v)** = in-degree (arrows coming IN)
  - **deg⁺(v)** = out-degree (arrows going OUT)

**Handshaking Theorem (Theorem 10.2.1) — MEMORIZE:**
$$\sum_{v \in V} \deg(v) = 2|E|$$

Why? Every edge contributes 2 to total degree sum (one for each endpoint).

**Corollary:** Number of vertices with ODD degree is always EVEN.

**For directed graphs (Theorem 10.2.3):**
$$\sum_{v \in V} \deg^-(v) = \sum_{v \in V} \deg^+(v) = |E|$$

### Special Named Graphs

| Graph | Description | Vertices | Edges |
|---|---|---|---|
| **K_n** | Complete: every vertex connected to every other | n | n(n-1)/2 |
| **C_n** | Cycle: vertices in a ring | n | n |
| **W_n** | Wheel: C_n + one hub vertex connected to all | n+1 | 2n |
| **Q_n** | n-cube: vertices = n-bit strings; edges connect strings differing by 1 bit | 2^n | n·2^(n-1) |

**K_n:** K_3 = triangle. K_4 = every pair among 4 people shakes hands.
**Q_3:** corners of a 3D cube. Each corner has 3 neighbors (flip one bit at a time).

### Bipartite Graphs

**Analogy:** Split everyone into Team A and Team B. Edges ONLY go between teams, never within same team.

**Definition:** G = (V,E) is bipartite if V splits into disjoint V₁, V₂ where every edge connects V₁ to V₂.

**Theorem 10.2.4:** Simple graph is bipartite iff:
- It can be **2-colored** (adjacent vertices get different colors), AND equivalently
- All its **cycles are even-length**

**Complete bipartite K_{m,n}:** Every vertex in V₁ (size m) connects to every vertex in V₂ (size n). Has m·n edges.

**How to check bipartite:** 2-color it. Pick a vertex → color red. Color all neighbors blue. Color all their unvisited neighbors red. If any vertex needs both colors → NOT bipartite.

---

## 10.3 — Representing Graphs

### Adjacency List
For each vertex, list all neighbors.

```
Vertex | Adjacent Vertices
a      | b, c, d
b      | a, c
c      | a, b
d      | a
```

Best for **sparse** graphs (few edges).

### Adjacency Matrix
n×n matrix where a_{ij} = 1 if edge exists, 0 otherwise.

```
   a  b  c  d
a [0  1  1  1]
b [1  0  1  0]
c [1  1  0  0]
d [1  0  0  0]
```

Rules by type:
- **Simple:** symmetric; diagonal all 0
- **Multigraph:** a_{ij} = number of edges between v_i and v_j (i≠j); a_{ii} = loops
- **Directed:** a_{ij} = 1 if (v_i → v_j); NOT necessarily symmetric
- **Directed multigraph:** a_{ij} = number of directed edges from v_i to v_j

Best for **dense** graphs or quick adjacency checks.

---

## 10.3 — Graph Isomorphism

### The Analogy
Two maps that look different but describe the exact same road network — just with different city names and drawn differently. The underlying structure is identical.

### What's Actually Happening

G₁ = (V₁,E₁) and G₂ = (V₂,E₂) are **isomorphic** if there exists a bijection f: V₁ → V₂ such that:

> {a, b} ∈ E₁  ←→  {f(a), f(b)} ∈ E₂

a and b are adjacent in G₁ **if and only if** their images are adjacent in G₂.

### Invariants (check FIRST — necessary but NOT sufficient)

Isomorphic graphs MUST share:
1. Same **number of vertices**
2. Same **number of edges**
3. Same **degree sequence** (sorted list of all degrees)

**CRITICAL TRAP:** These are necessary but NOT sufficient. Same invariants ≠ isomorphic. You still need to find/rule out the bijection.

**Exam strategy:**
1. Check invariants → if any differ, NOT isomorphic. Done.
2. If match → explicitly construct bijection f. Match high-degree to high-degree. Verify adjacency preserved.
3. If f works → isomorphic. If impossible → not isomorphic.

---

## 10.4 — Connectivity

### The Analogy
A road network is "connected" if you can drive anywhere from anywhere. Some cities are so critical that removing one splits the map into disconnected islands.

### Paths and Connectivity

- **Path:** sequence of vertices where each consecutive pair is an edge
- **Simple path:** no repeated vertices
- **Circuit:** path starting and ending at same vertex
- **Simple circuit:** circuit with no repeated vertices (except start=end)
- **Connected:** undirected graph with path between every pair of vertices

**Theorem 10.4.1:** Connected simple graph → simple path between every pair of distinct vertices.

### Cut Vertices and Edges

**Cut vertex (articulation point):** Removing it (+ incident edges) → more connected components. The "bottleneck" city.

**Cut edge (bridge):** Removing just this edge → more connected components. The "one critical road."

### Directed Graph Connectivity

**Strongly connected:** For EVERY pair a,b → directed path a→b AND directed path b→a. Can get anywhere AND return.

**Weakly connected:** Ignore directions → underlying undirected graph is connected.

**Strongly connected component:** Maximal subgraph that is strongly connected.

**Key:** Strongly connected ⊆ weakly connected. Weakly connected does NOT imply strongly connected.

---

## 10.5 — Euler and Hamilton Paths

### EULER — "Visit Every EDGE Once"

**Analogy:** The Königsberg Bridge Problem. 7 bridges — can you cross every bridge exactly once and return to start? Euler proved NO.

**Euler circuit:** Simple circuit using every edge exactly once. Start = end.
**Euler path:** Simple path using every edge exactly once. Start ≠ end.

**Theorem 10.5.1:** Connected multigraph has Euler circuit **iff** every vertex has **even degree**.

**Theorem 10.5.2:** Connected multigraph has Euler path but NOT circuit **iff** exactly **two vertices have odd degree**. (Those two = start and end.)

These are **both necessary AND sufficient (iff).**

**Intuition:** Euler circuit: enter=leave every vertex, so each visit uses 2 edges → need even degree. Euler path: start vertex has one "extra" departure; end vertex has one "extra" arrival → exactly 2 odd-degree vertices.

**Exam strategy — just count degrees:**
- All even → Euler circuit exists ✓
- Exactly 2 odd → Euler path exists (start/end at odd-degree vertices) ✓
- More than 2 odd → neither exists ✗

---

### HAMILTON — "Visit Every VERTEX Once"

**Analogy:** Traveling salesman visiting every city exactly once and returning home. MUCH harder — no simple condition exists.

**Hamilton path:** Visits every vertex exactly once. Start ≠ end.
**Hamilton circuit (cycle):** Visits every vertex exactly once. Start = end. Graph is *Hamiltonian*.

**No iff theorem exists.** Only sufficient and necessary conditions separately.

**SUFFICIENT conditions (true → Hamilton circuit, but not required for circuit to exist):**

**Dirac's Theorem (10.5.3):** Simple graph G, |V| ≥ 3.
If deg(v) ≥ |V|/2 for ALL v ∈ V → Hamilton circuit exists.

**Ore's Theorem (10.5.4):** Simple graph G, |V| ≥ 3.
If deg(u) + deg(v) ≥ |V| for ALL non-adjacent u, v ∈ V → Hamilton circuit exists.

**NECESSARY conditions (circuit exists → these must hold, but can't prove existence):**
- deg(v) ≥ 2 for all v
- G must NOT have a cut vertex or cut edge
- All edges incident to degree-2 vertices must be IN the Hamilton circuit

**CRITICAL TRAP:** Failing Dirac's/Ore's does NOT mean no Hamilton circuit. These are one-way. The necessary conditions let you rule OUT, not prove IN.

---

# ═══════════════════════════════════
# CHAPTER 11: TREES (11.1, 11.3–11.4)
# ═══════════════════════════════════

---

## 11.1 — Introduction to Trees

### The Analogy
A family tree. One ancestor (root) at top, children below, grandchildren further down. No cycles — you can't be your own ancestor. Only one path between any two family members.

### What's Actually Happening

**Tree:** Connected undirected graph with **no cycles**.

**Theorem 11.1.1:** Undirected graph is a tree **iff** there is a **unique** simple path between any pair of vertices.

**Theorem 11.1.2 — MEMORIZE COLD:** A tree with **n vertices has exactly n − 1 edges**.

### Rooted Tree Vocabulary

| Term | Meaning |
|---|---|
| **Root** | Top vertex; has no parent |
| **Parent** | One step toward root |
| **Child** | One step away from root |
| **Leaf** | Vertex with no children |
| **Internal vertex** | Non-leaf; has ≥1 child |
| **Sibling** | Vertices sharing same parent |
| **Ancestor** | Any vertex on path from root to v |
| **Descendant** | Any vertex for which v is ancestor |
| **Level of v** | Path length from root to v (root = level 0) |
| **Height** | Maximum level in tree |
| **Subtree** | A vertex + all its descendants |

### m-ary Trees

- **m-ary tree:** Every internal vertex has **at most m** children
- **Full m-ary tree:** Every internal vertex has **exactly m** children
- **Binary tree:** m = 2 (most common)
- **Balanced m-ary tree:** All leaves at level h or h−1

### Theorem 11.1.4 — Full m-ary Tree Formulas

Variables: n = total vertices, i = internal vertices, l = leaves (l = n − i)

**(i) Given n:**
- i = (n − 1)/m
- l = [(m − 1)n + 1]/m

**(ii) Given i internal vertices:**
- n = mi + 1  ← **most useful to memorize**
- l = (m − 1)i + 1

**(iii) Given l leaves:**
- n = (ml − 1)/(m − 1)
- i = (l − 1)/(m − 1)

**Why n = mi + 1?**
Each internal vertex contributes exactly m children. So m·i total parent→child edges. Every vertex except the root is someone's child. So: i children are internal, l are leaves → i + l = m·i + 1 ... rearranges to n = mi + 1.

**Practice examples:**
- Full 4-ary tree with 10 internal vertices:  n = 4(10)+1 = 41,  l = 3(10)+1 = 31
- Full 3-ary tree with 13 vertices:  i = (13-1)/3 = 4,  l = (2·13+1)/3 = 9

### Height vs Leaves — Theorem 11.1.5 & Corollary 11.1.1

**Theorem 11.1.5:** m-ary tree of height h has **at most m^h leaves**.

Why: Each level multiplies max nodes by m. After h levels: m^h.

**Corollary 11.1.1:**
1. m-ary tree of height h with l leaves: **h ≥ ⌈log_m l⌉**
2. If full AND balanced: **h = ⌈log_m l⌉** (exact, not just bound)

**Example: full m-ary tree, 81 leaves, height 4.**
- From Thm 11.1.5: 81 ≤ m^4 → m ≥ 81^(1/4) = 3 → m ≥ 3
- If balanced: h = ⌈log_m 81⌉ = 4 → m^4 = 81 → m = 3

---

## 11.3 — Tree Traversal

### The Analogy
Exploring a tree-shaped cave system. Traversal = a specific strategy for WHICH rooms you write down and WHEN, relative to exploring the tunnels branching off each room.

### Three Traversal Orders

All three visit every vertex exactly once. Difference: WHEN you process the root vs its subtrees.

**PREORDER (Root, then subtrees left-to-right):**
1. Visit root
2. Visit subtree T₁ in preorder
3. Visit T₂ in preorder ... Visit Tₙ in preorder

**INORDER (T₁, then Root, then T₂...Tₙ) — strictly for binary trees:**
1. Visit left subtree T₁ in inorder
2. Visit root
3. Visit right subtree T₂ in inorder

**POSTORDER (all subtrees, then Root last):**
1. Visit T₁ in postorder
2. Visit T₂ in postorder ... Visit Tₙ in postorder
3. Visit root last

### Memory Trick

| Traversal | When root visited | Notation type |
|---|---|---|
| Preorder | FIRST | Prefix (root op first: + a b) |
| Inorder | MIDDLE | Infix (normal math: a + b) |
| Postorder | LAST | Postfix/RPN (a b +) |

### Example

Tree:
```
        a
      / | \
     b  c  d
    /|   \
   f  g   e
```

- **Preorder:** a → b → f → g → c → e → d
- **Inorder:** f → b → g → a → e → c → d
- **Postorder:** f → g → b → e → c → d → a

**Exam approach:** Label each vertex with "when do I write it" — before, between, or after recursing. Practice until mechanical.

---

## 11.4 — Spanning Trees

### The Analogy
Big connected road network. Keep the fewest roads possible while still connecting all cities. That minimal connected set = spanning tree.

### Definition

**Spanning tree** of connected simple graph G:
- Is a tree (connected + acyclic)
- Contains ALL vertices of G
- Has exactly n−1 edges

Every connected simple graph has a spanning tree (guaranteed).

---

### Depth-First Search (DFS) — "Go Deep, Then Backtrack"

**Analogy:** Maze explorer always takes the first unexplored tunnel. Dead end → backtrack to last fork with unexplored paths.

**Algorithm:**
1. Pick any vertex as root → add to tree
2. From current vertex, pick any unvisited adjacent vertex → add vertex + edge to tree → move there
3. Repeat step 2
4. Stuck? Backtrack to previous vertex, try again from there
5. Continue until all vertices visited

**Result:** Tall, skinny tree — long paths before backtracking.

---

### Breadth-First Search (BFS) — "Go Wide, Level by Level"

**Analogy:** Ripple in a pond from a dropped stone. All distance-1 points hit first, then distance-2, etc.

**Algorithm:**
1. Pick any vertex as root → Level 0
2. Add ALL unvisited neighbors → Level 1
3. For each Level 1 vertex: add ALL their unvisited neighbors → Level 2
4. Repeat for each subsequent level
5. Continue until all vertices added

**Result:** Short, wide tree — all equidistant nodes at same level.

---

### Minimum Spanning Trees (MST)

When edges have weights, minimize total weight of spanning tree.

**MST:** Spanning tree with minimum sum of edge weights.

#### Prim's Algorithm — "Grow from a seed"

1. Pick minimum-weight edge globally → add both endpoints + edge to tree
2. Repeat: pick minimum-weight edge connecting a tree-vertex to a non-tree-vertex
3. Stop when n−1 edges added

**Always maintains one growing connected component.**

#### Kruskal's Algorithm — "Sort all, add if safe"

1. Pick minimum-weight edge globally → add to tree
2. Repeat: pick minimum-weight edge among ALL remaining that does NOT create a cycle
3. Stop when n−1 edges added

**Can jump around the graph — components merge as algorithm runs.**

**Prim vs Kruskal:**

| | Prim | Kruskal |
|---|---|---|
| Growth | One component expands | Multiple components merge |
| Connected at each step? | Yes | Not necessarily |
| Better for | Dense graphs | Sparse graphs |

Both always produce a valid MST. Both are greedy. Both give same total weight (may differ in edge selection if ties exist).

---

# ═══════════════════════
# KEY TERMS REFERENCE
# ═══════════════════════

## Chapter 10 Terms

| Term | Definition |
|---|---|
| **Simple graph** | Undirected; ≤1 edge per pair; no self-loops |
| **Multigraph** | Undirected; multiple edges allowed; no self-loops |
| **Pseudograph** | Undirected; multiple edges + self-loops allowed |
| **Simple directed graph** | Directed; ≤1 edge per ordered pair |
| **Directed multigraph** | Directed; multiple edges per ordered pair |
| **deg(v)** | Number of edges incident to v |
| **deg⁻(v)** | In-degree: arrows coming in to v |
| **deg⁺(v)** | Out-degree: arrows going out from v |
| **Handshaking Theorem** | Σdeg(v) = 2|E| |
| **K_n** | Complete graph on n vertices |
| **C_n** | Cycle graph on n vertices |
| **W_n** | Wheel graph: C_n + hub |
| **Q_n** | n-cube/hypercube |
| **Bipartite** | V splits into two groups; edges only cross |
| **K_{m,n}** | Complete bipartite graph |
| **Adjacency list** | List neighbors of each vertex |
| **Adjacency matrix** | Grid: 1=edge, 0=no edge |
| **Isomorphic** | Same structure; bijection preserving adjacency |
| **Degree sequence** | Sorted list of all vertex degrees |
| **Connected** | Path exists between every pair |
| **Cut vertex** | Removal increases connected components |
| **Cut edge (bridge)** | Removal increases connected components |
| **Strongly connected** | Directed: path in both directions between all pairs |
| **Weakly connected** | Directed: connected when arrows ignored |
| **Euler circuit** | Every edge once; start = end; requires all even degrees |
| **Euler path** | Every edge once; start ≠ end; requires exactly 2 odd-degree vertices |
| **Hamilton circuit** | Every vertex once; start = end |
| **Hamilton path** | Every vertex once; start ≠ end |
| **Dirac's Theorem** | deg(v) ≥ |V|/2 for all v → Hamilton circuit (sufficient) |
| **Ore's Theorem** | deg(u)+deg(v) ≥ |V| for non-adjacent pairs → Hamilton circuit (sufficient) |

## Chapter 11 Terms

| Term | Definition |
|---|---|
| **Tree** | Connected acyclic undirected graph |
| **n−1 edges** | ALWAYS: tree with n vertices has n−1 edges |
| **Root** | Designated top vertex; no parent |
| **Leaf** | No children |
| **Internal vertex** | Has ≥1 child |
| **Height** | Maximum level; root is level 0 |
| **m-ary tree** | Each internal vertex has ≤m children |
| **Full m-ary tree** | Each internal vertex has exactly m children |
| **Balanced** | All leaves at level h or h−1 |
| **Preorder** | Root → subtrees (root first) |
| **Inorder** | Left subtree → root → right subtrees |
| **Postorder** | All subtrees → root (root last) |
| **Spanning tree** | Tree subgraph containing all vertices of G |
| **DFS** | Go deep first; backtrack when stuck |
| **BFS** | Go wide first; level by level |
| **MST** | Spanning tree minimizing total edge weight |
| **Prim's Algorithm** | Grow one component; always pick cheapest edge to new vertex |
| **Kruskal's Algorithm** | Sort all edges; add cheapest that doesn't form cycle |

---

# ════════════════════════
# COMMON EXAM TRAPS
# ════════════════════════

1. **Euler ≠ Hamilton.** Euler visits every EDGE (use degree parity). Hamilton visits every VERTEX (no simple condition). Never cross these.

2. **Dirac's/Ore's are sufficient, not necessary.** Failing these theorems does NOT rule out Hamilton circuits. Cannot use them to prove no circuit exists.

3. **Isomorphism invariants are necessary, not sufficient.** Same degree sequence ≠ isomorphic. Always construct explicit bijection.

4. **n−1 edges is for TREES only.** A connected graph has AT LEAST n−1 edges. Exactly n−1 iff it's a tree.

5. **Strongly ≠ weakly connected.** Strongly implies weakly. Weakly does NOT imply strongly. Always check direction.

6. **Full m-ary formulas require "full."** If tree only has ≤m children per vertex (not exactly m), Theorem 11.1.4 does NOT apply.

7. **Height vs level.** Root = level 0. A tree of height 3 has leaves at level 3, not 4. Off-by-one kills exam points.

8. **Prim and Kruskal produce MSTs of same total weight**, but may choose different edges when ties exist. Both are correct MSTs.

9. **Bipartite ↔ no odd cycles.** Presence of any triangle (3-cycle) or 5-cycle immediately means NOT bipartite.

10. **Cut vertex removes all incident edges too.** Don't just "remove the vertex" in your mind — all edges incident to it go with it.

---

# ═══════════════════
# MODULE SUMMARY
# ═══════════════════

**Chapter 10 big picture:** Graph theory formalizes connections. The vocabulary (degree, paths, circuits, types) builds up to powerful theorems. Euler's degree-parity conditions are elegant iff statements. Hamilton is the unsolved-style problem with only one-way conditions. Isomorphism requires finding structural bijections, not just matching invariants.

**Chapter 11 big picture:** Trees are the minimal connected structure — exactly n−1 edges to hold n vertices together with no redundancy. Rooted trees add hierarchy. Traversals give systematic ways to visit every node. Spanning trees extract a connected backbone from any graph. DFS digs deep; BFS sweeps wide. MST algorithms are greedy and guaranteed correct.

**Now you can understand:**
- Why DFS and BFS underlie almost every graph algorithm in CS (shortest path, topological sort)
- Why binary trees power database indexes (B-trees are m-ary trees)
- Why Euler's bridge problem (1736) was the birth of graph theory
- How Hamilton circuits connect to NP-hard problems (Traveling Salesman)
