import { request } from './request'

export const getLatestTask = async () => {
  const res = await request({
    url: 'personnelEvaluation/listObtainPersonnelEvaluationTasks',
    data: { pageNum: 1, pageSize: 1 }
  })
  const list = res.data?.list || []
  return list[0] || null
}

export const getQuestionnaireList = async (taskId) => {
  const res = await request({
    url: 'evaluationMethodSix/getQuestionnaireListToTask',
    data: { rwid: taskId, pageNum: 1, pageSize: 999 }
  })
  return res.data?.list || []
}

export const getCourseList = async (qid) => {
  const res = await request({
    url: 'evaluationMethodSix/getRequiredReviewsData',
    data: { sfyp: 0, wjid: qid, pageNum: 1, pageSize: 999 }
  })
  return res.data?.list || []
}
