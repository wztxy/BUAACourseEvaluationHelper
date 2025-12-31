const SSO_URL = 'https://sso.buaa.edu.cn/login'
const TARGET = 'https://spoc.buaa.edu.cn/pjxt/authentication/main'

export const getToken = async () => {
  const res = await uni.request({
    url: `${SSO_URL}?service=${TARGET}`,
    method: 'GET'
  })
  const match = res.data.match(/name="execution" value="([^"]+)"/)
  return match ? match[1] : null
}

export const login = async (username, password) => {
  const token = await getToken()
  if (!token) return { success: false, msg: '获取token失败' }

  const res = await uni.request({
    url: `${SSO_URL}?service=${TARGET}`,
    method: 'POST',
    header: { 'Content-Type': 'application/x-www-form-urlencoded' },
    data: {
      username,
      password,
      execution: token,
      _eventId: 'submit',
      type: 'username_password',
      submit: 'LOGIN'
    }
  })

  const success = res.data.includes('authentication/main')
  return { success, msg: success ? '登录成功' : '用户名或密码错误' }
}
