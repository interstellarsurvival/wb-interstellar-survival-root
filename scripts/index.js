module.exports = async function main (callback) {
  try {
    // Our code will go here

    callback(0);
  } catch (error) {
    console.error(error);
    callback(1);
  }
};
