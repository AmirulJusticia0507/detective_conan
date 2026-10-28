import assert from 'node:assert/strict'
import test from 'node:test'
import { HttpError, parsePositiveInt, validateLatLng, validateRadius } from '../src/utils/validate.js'

test('parsePositiveInt hanya menerima bilangan bulat positif', () => {
  assert.equal(parsePositiveInt('12', 'id'), 12)
  assert.throws(() => parsePositiveInt('0', 'id'), HttpError)
  assert.throws(() => parsePositiveInt('1.5', 'id'), HttpError)
})

test('validasi koordinat dan radius menolak nilai di luar batas', () => {
  assert.deepEqual(validateLatLng('-6.2', '106.8'), { lat: -6.2, lng: 106.8 })
  assert.equal(validateRadius(), 120)
  assert.equal(validateRadius('50'), 50)
  assert.throws(() => validateLatLng(91, 0), HttpError)
  assert.throws(() => validateRadius(501), HttpError)
})
