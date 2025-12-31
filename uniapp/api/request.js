const BASE_URL = 'https://spoc.buaa.edu.cn/pjxt/'

export const request = (options) => {
  return new Promise((resolve, reject) => {
    uni.request({
      url: BASE_URL + options.url,
      method: options.method || 'GET',
      data: options.data,
      header: options.header,
      success: (res) => resolve(res.data),
      fail: (err) => reject(err)
    })
  })
}
