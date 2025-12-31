// 生成好评答案
export const genGoodAnswer = (questions) => {
  return questions.map((q, i) => {
    const opts = q.options.sort((a, b) => b.pts - a.pts)
    return i === 0 && opts.length > 1 ? opts[1] : opts[0]
  })
}

// 动态规划生成目标分数答案
export const genTargetAnswer = (questions, target) => {
  const maxScore = questions.reduce((s, q) => s + Math.max(...q.options.map(o => o.pts)), 0)
  const dp = new Array(maxScore + 1).fill(false)
  const path = new Array(maxScore + 1).fill(null).map(() => [])
  dp[0] = true

  for (let i = 0; i < questions.length; i++) {
    const newDp = [...dp]
    const newPath = path.map(p => [...p])
    for (let s = 0; s <= maxScore; s++) {
      if (!dp[s]) continue
      questions[i].options.forEach((opt, j) => {
        const ns = s + opt.pts
        if (ns <= maxScore && !newDp[ns]) {
          newDp[ns] = true
          newPath[ns] = [...path[s], j]
        }
      })
    }
    dp.splice(0, dp.length, ...newDp)
    path.splice(0, path.length, ...newPath)
  }

  for (let s = target; s <= maxScore; s++) {
    if (dp[s]) return path[s].map((j, i) => questions[i].options[j])
  }
  return genGoodAnswer(questions)
}
